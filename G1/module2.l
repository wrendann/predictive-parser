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
%}

whitespace [ \t]
%%


[\n\r] {}
{whitespace} {}
<<EOF>> {return -1;}
. {
	for(int i = 1; i<MAX_COLS; i++)
	{
		if(strcmp(parsingTable[0][i], yytext)==0)
			return 1;
		if(strcmp(parsingTable[0][i], "~") == 0)
			return 0;
	}
	return 0;
}
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
		addToStack(stack, &top, "S");
		int result = -1;
		while ((result = yylex()) >= 0)
		{
			if(result == 0)
			{
				printf("Tokenization error, %s not defined.\n", yytext);
				accepted = 0;
				break;
			}
			if(strcmp(yytext, "") == 0)
				continue;
			while(1)
			{
				if(strcmp(yytext, stack[top]) == 0)
				{
					top--;
					break;
				}
				int A = findNonTerminal(parsingTable, stack[top], rowNum);
				int b = findTerminal(parsingTable, yytext);
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
				printf("%s -> %s\n", lhs, rhs);
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