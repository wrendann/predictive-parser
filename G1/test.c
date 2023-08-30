#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define ERROR -1
#define MAX_ROWS 100    // Maximum number of rows in the CSV
#define MAX_COLS 100    // Maximum number of columns in the CSV
#define MAX_LINE_LENGTH 50   // Maximum length of a line in the CSV

int main()
{
		char parsingTable[MAX_ROWS][MAX_COLS][MAX_LINE_LENGTH];
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
					parsingTable[a][b][c] = '\0';
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
    fclose(file);
		parsingTable[a][b][c] = '\0';
		int rowNum = a;
		for(int i = 0; i<rowNum; i++)
		{
			for(int j = 0; j<MAX_COLS && parsingTable[i][j][0] != '~'; j++)
				printf("%s\t", parsingTable[i][j]);
			printf("\n");
		}
		return 0;
 }