%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"
	
	int yylex(void);
	void yyerror(char* s);
	extern int yylval;
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
"class" { printf("%s - Class keyword\n",yytext); return CLASS; }
"new" { printf("%s - New keyword\n",yytext); return NEW; }
"return" { printf("%s - Return keyword\n",yytext); return RETURN; }
"static" { printf("%s - Static keyword\n",yytext); return STATIC; }
"if" { printf("%s - If keyword\n",yytext); return IF; }
"else" { printf("%s - Else keyword\n",yytext); return ELSE; }
"for" { printf("%s - For keyword\n",yytext); return FOR; }
"System.out.println" { printf("%s - print statement\n",yytext); return PRINT; }
{newline} { line++; }
{space}+ { }
{single_comment} { printf("%s - Single line Comment\n",yytext); }
{multi_comment} { printf("%s - Multi Line Comment\n",yytext); line+=num_of_newlines(yytext); }
{visibility} { printf("%s - Visibility\n",yytext); return VISIBILITY; }
{data_type} { printf("%s - Data Type\n",yytext); return DATA_TYPE; }
{keyword} { printf("%s - Keyword\n",yytext); return *yytext; }
{id} { printf("%s - Identifier\n",yytext); return ID; }
[=] { printf("%s - Assignment Operator\n",yytext); return *yytext; }
{hex_const}|{number} { printf("%s - Integer Constant\n",yytext); return NUMBER; }
{float_number} { printf("%s - Floating point Constant\n",yytext); return NUMBER; }
{arithmetic}[=] { printf("%s - Arithmetic Assignment Operator\n",yytext); return ARITH_ASSIGN_OP; }
{logical} { printf("%s - Logical Operator\n",yytext); return LOGICAL_OP; }
{bitwise} { printf("%s - Bitwise Operator\n",yytext); return BITWISE_OP; }
{unary} { printf("%s - Unary Operator\n",yytext); return UNARY_OP; }
{relational} { printf("%s - Relational Operator\n",yytext); return RELATIONAL_OP; }
{arithmetic} { printf("%s - Arithmetic Operator\n",yytext); return ARITHMETIC_OP; }
{char_const} { printf("%s - Character Constant\n",yytext); return CHAR; }
{string_const} { printf("%s - String Constant\n",yytext); return STRING; }
{special} { printf("%s - Special Character\n",yytext); return *yytext; }
%%
