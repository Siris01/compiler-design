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

	#define YYSTYPE char *
	#define DEBUG 0 //set to 1 for debbuging syntax errors

	void print(char* str) {
		if (DEBUG) printf("%s\n", str);
	}
%}

digit   [0-9]
letter  [A-Za-z]
hex_const 0[xX][a-fA-F0-9]+
number [0-9]+
float_number	"0"|[0-9]+"."[0-9]+
id  [a-zA-Z_][a-zA-Z0-9_]*
space   [ \t]
special "."|","|"("|")"|"["|"]"|"{"|"}"|";"
visibility "public"|"private"|"protected"
data_type "int"|"float"|"double"|"char"|"bool"|"string"|"void"|"String"
keyword "public"|"private"|"protected"|"void"|"static"|"class"|"new"|"if"|"else"|"for"|"while"|"return"|"switch"|"case"|"break"|"continue"|{data_type}
arithmetic "+"|"-"|"*"|"/"|"%"
relational ">"|"<"|">="|"<="|"!="|"=="
unary   "++"|"--"
arith_assign "+="|"-="|"*="|"/="|"%="
logical "&&"|"||"|"!"
bitwise "&"|"|"|"^"|"<<"|">>"
single_comment  "//".*
newline \n
multi_comment "/*"[^*/]*"*/"
char_const '.*'
string_const \"[^"\n]*\"

%%
"class" { print(yytext); return CLASS; }
"new" { print(yytext); return NEW; }
"return" { print(yytext); return RETURN; }
"static" { print(yytext); return STATIC; }
"if" { print(yytext); return IF; }
"else" { print(yytext); return ELSE; }
"for" { print(yytext); return FOR; }
"System.out.println" { print(yytext); return PRINT; }
{newline} { line++; }
{space}+ { }
{single_comment} { }
{multi_comment} { line+=num_of_newlines(yytext); }
{visibility} { print(yytext); return VISIBILITY; }
{data_type} { print(yytext); return DATA_TYPE; }
{keyword} { print(yytext); return *yytext; }
{id} { yylval.str = strdup(yytext); print(yytext); return ID; }
[=] { yylval.str = strdup(yytext); print(yytext); return *yytext; }
{hex_const}|{number} { yylval.str = strdup(yytext); print(yytext); return NUMBER; }
{float_number} { yylval.str = strdup(yytext); print(yytext); return NUMBER; }
{arithmetic}[=] { yylval.str = strdup(yytext); print(yytext); return ARITH_ASSIGN_OP; }
{logical} { yylval.str = strdup(yytext); print(yytext); return LOGICAL_OP; }
{bitwise} { yylval.str = strdup(yytext); print(yytext); return BITWISE_OP; }
{unary} { yylval.str = strdup(yytext); print(yytext); return UNARY_OP; }
{relational} { yylval.str = strdup(yytext); print(yytext); return RELATIONAL_OP; }
{arithmetic} { yylval.str = strdup(yytext); print(yytext); return ARITHMETIC_OP; }
{char_const} { yylval.str = strdup(yytext); print(yytext); return CHAR; }
{string_const} { yylval.str = strdup(yytext); print(yytext); return STRING; }
{special} { yylval.str = strdup(yytext); print(yytext); return *yytext; }
. { print(yytext); return *yytext; }
%%
