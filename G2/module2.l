%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_ROWS 100    
#define MAX_COLS 100    
#define MAX_LINE_LENGTH 50   
#define MAX_STACK_SIZE 100
#define MAX_SYMBOL_LENGTH 10
char parsingTable[MAX_ROWS][MAX_COLS][MAX_LINE_LENGTH];
char token[MAX_SYMBOL_LENGTH];
%}

whitespace [ \t]
digit [0-9]
digits ({digit}+)
decimal_digits (.{digits})
exponential (e[+-]?{digits})
integer ({digits}{exponential}?)
floating_point ({digits}{decimal_digits}?{exponential}?f?)
str ("[^']")
letter [a-zA-Z]
l_or_d ({letter}|{digit})
identifier ({letter}{l_or_d}*)
%%

{whitespace} {}
[\n\r] {}
<<EOF>> {return -1;}
"+" {strcpy(token, yytext); return 1;}
"-" {strcpy(token, yytext); return 1;}
"∗" {strcpy(token, yytext); return 1;}
"/" {strcpy(token, yytext); return 1;}
:= {strcpy(token, yytext); return 1;}
"=" {strcpy(token, yytext); return 1;}
"<" {strcpy(token, yytext); return 1;}
">" {strcpy(token, yytext); return 1;}
"(" {strcpy(token, yytext); return 1;}
")" {strcpy(token, yytext); return 1;}
"{" {strcpy(token, yytext); return 1;}
"}" {strcpy(token, yytext); return 1;}
";" {strcpy(token, yytext); return 1;}
and {strcpy(token, yytext); return 1;}
else {strcpy(token, yytext); return 1;}
end {strcpy(token, yytext); return 1;}
then {strcpy(token, yytext); return 1;}
while {strcpy(token, yytext); return 1;}
not {strcpy(token, yytext); return 1;}
or {strcpy(token, yytext); return 1;}
print {strcpy(token, yytext); return 1;}
prog {strcpy(token, yytext); return 1;}
scan {strcpy(token, yytext); return 1;}
if {strcpy(token, yytext); return 1;}
int {strcpy(token, yytext); return 1;}
do {strcpy(token, yytext); return 1;}
float {strcpy(token, yytext); return 1;}
{integer} {strcpy(token, "ic"); return 1;}
{identifier} {strcpy(token, "id"); return 1;}
{floating_point} {strcpy(token, "fc"); return 1;}
{str} {strcpy(token, "str"); return 1;}
. {return 0;}
%%

int yywrap(void) {return 1;}

void addToStack(char stack[][MAX_SYMBOL_LENGTH], int* top, char symbol[])
{
	if(strcmp(symbol, "epsilon") == 0)
		return;
	*(top) = *(top) + 1;
	int i = 0;
	for(; i<strlen(symbol); i++)
	{
	    stack[*top][i] = symbol[i];
	}
	stack[*top][i] = '\0';
}

void addSymbolsToStack(char stack[][MAX_SYMBOL_LENGTH], int* top, char line[])
{
	char symbols[MAX_STACK_SIZE][MAX_SYMBOL_LENGTH];
	int j = 0, k = 0;
	for(int i = 0; i<strlen(line); i++)
	{
		char c = line[i];
		if(c == ' ')
		{
			symbols[j][k] = '\0';
			j++;
			k = 0;
		}
		else
		{
			symbols[j][k] = c;
			k++;
		}
	}
	symbols[j][k] = '\0';
	for(; j>=0; j--)
	{
		addToStack(stack, top, symbols[j]);
	}
}

int findTerminal(char parsingTable[MAX_ROWS][MAX_COLS][MAX_LINE_LENGTH], char terminal[])
{
	for(int i = 1; i<MAX_COLS; i++)
	{
		if(strcmp(parsingTable[0][i], terminal)==0)
			return i;
		if(strcmp(parsingTable[0][i], "~") == 0)
			return -1;
	}
	return -1;
}

int findNonTerminal(char parsingTable[MAX_ROWS][MAX_COLS][MAX_LINE_LENGTH], char nonTerminal[], int rowNum)
{
	for(int i = 1; i<rowNum; i++)
	{
		if(strcmp(parsingTable[i][0], nonTerminal)==0)
			return i;
	}
	return -1;
}

int main()
{
		yyin=fopen("input.txt","r");
		FILE *file;
		char ch;
		file = fopen("parsing-table.csv", "r");
		if (file == NULL) {
				perror("Error opening file");
				return 1;
		}
		int a = 0, b = 0, c = 0;
		while ((ch = fgetc(file)) != EOF && a < MAX_ROWS && b < MAX_COLS && c < MAX_LINE_LENGTH) {
				if(ch == ','){
					parsingTable[a][b][c] = '\0';
					c = 0;
					b++;
				}
				else if(ch == '\n'){
					parsingTable[a][b][c-1] = '\0';
					parsingTable[a][b+1][0] = '~';
					parsingTable[a][b+1][1] = '\0';
					c = 0;
					b = 0;
					a++;
				}
				else
				{
					parsingTable[a][b][c] = ch;
					c++;
				}
		}
		parsingTable[a][b][c] = '\0';
		int rowNum = a;

		char stack[MAX_STACK_SIZE][MAX_SYMBOL_LENGTH];
		int top = -1;
		int accepted = 1;
		addToStack(stack, &top, "$");
		addToStack(stack, &top, "P");
		int result = -1;
		while ((result = yylex()) >= 0)
		{
			if(result == 0)
			{
				printf("Tokenization error, not defined %s.\n", yytext);
				accepted = 0;
				break;
			}
			if(strcmp(token, "") == 0)
				continue;
			while(1)
			{
				if(strcmp(token, stack[top]) == 0)
				{
					top--;
					break;
				}
				int A = findNonTerminal(parsingTable, stack[top], rowNum);
				int b = findTerminal(parsingTable, token);
				if(A == -1 || b == -1)
				{
					accepted = 0;
					break;
				}
				char* lhs = stack[top];
				if(stack[top][0] != '$')
				{
					top--;
				}
				char rhs[MAX_LINE_LENGTH];
				strcpy(rhs, parsingTable[A][b]);
				printf("%s %s -> %s\n", token, lhs, rhs);
				addSymbolsToStack(stack, &top, rhs);
			}
			if(accepted == 0)
				break;
		}
		while(top > 0 && accepted == 1)
		{
			int A = findNonTerminal(parsingTable, stack[top], rowNum);
			int b = findTerminal(parsingTable, "$");
			if(A == -1 || b == -1)
			{
				accepted = 0;
				break;
			}
			char* lhs = stack[top];
			if(stack[top][0] != '$')
				top--;
			char rhs[MAX_LINE_LENGTH];
			strcpy(rhs, parsingTable[A][b]);
			printf("%s -> %s\n", lhs, rhs);
			addSymbolsToStack(stack, &top, rhs);
		}
		if(accepted)
		{
			printf("Accepted!\n");
		}
		else
		{
			printf("Not Accepted!\n");
		}

		return 0;
 }