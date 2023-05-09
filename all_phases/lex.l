%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"
	
	int yylex(void);
	void yyerror(char* s);
	int line=0;

	int num_of_newlines(char *str) {
		int count=0, i=0;
		while(str[i]!='\0') {
			if(str[i]=='\n')
				count++;
			i++;
		}
		
		return count;
	}

	#define YYSTYPE char*
	#define DEBUG 1 //set to 1 for debbuging syntax errors

	void print(char* str) {
		if (DEBUG) printf("%s\n", str);
	}
%}

number [0-9]+
id  [a-zA-Z_][a-zA-Z0-9_]*
space   [ \t]
visibility "public"|"private"|"protected"
data_type "int"|"float"|"double"|"char"|"bool"|"string"|"void"|"String"
keyword "public"|"private"|"protected"|"void"|"static"|"class"|"new"|"if"|"else"|"for"|"while"|"return"|"switch"|"case"|"break"|"continue"|{data_type}
arithmetic "+"|"-"|"*"|"/"|"%"
single_comment  "//".*
newline \n
multi_comment "/*"[^*/]*"*/"

%%
"class" { print(yytext); return CLASS; }
"static" { print(yytext); return STATIC; }
{newline} { line++; }
{space}+ { }
{single_comment} { }
{multi_comment} { line+=num_of_newlines(yytext); }
{visibility} { print(yytext); return VISIBILITY; }
{data_type} { print(yytext); return DATA_TYPE; }
{keyword} { print(yytext); return *yytext; }
{id} { yylval.str = strdup(yytext); print(yytext); return ID; }
[=] { yylval.str = strdup(yytext); print(yytext); return *yytext; }
{number} { yylval.str = strdup(yytext); print(yytext); return NUMBER; }
{arithmetic}[=] { yylval.str = strdup(yytext); print(yytext); return ARITH_ASSIGN_OP; }
{arithmetic} { yylval.str = strdup(yytext); print(yytext); return ARITHMETIC_OP; }
. { print(yytext); return *yytext; }
%%
