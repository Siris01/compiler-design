%{
	#include<stdio.h>
%}

digit   [0-9]
letter  [A-Za-z]
hex_const 0[xX][a-fA-F0-9]+
number [0-9]+
float_number	"0"|[0-9]+"."[0-9]+
id  [a-zA-Z_][a-zA-Z0-9_]*
array {id}\[[^\]]*\]
space   [ \t]
special "."|","|"("|")"|"["|"]"|"{"|"}"|";"
pred	#.*
data_type "int"|"float"|"double"|"char"|"bool"
keyword "public"|"private"|"protected"|"void"|"static"|"class"|"new"|"if"|"else"|"for"|"while"|"return"|"switch"|"case"|"break"|"continue"|{data_type}
function ({id}"."?)+\s*\([^\)]*\)
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
{pred} { printf("%s - Predecessor Directive\n",yytext); }
{newline} { }
{space}+ { }
{single_comment} { printf("%s - Single line Comment\n",yytext); }
{multi_comment} { printf("%s - Multi Line Comment\n",yytext); }
{keyword} { printf("%s - Keyword\n",yytext); }
{id} { printf("%s - Identifier\n",yytext); }
{array} { printf("%s - Array\n",yytext); }
{function} { printf("%s - Function\n",yytext); }
[=] { printf("%s - Assignment Operator\n",yytext); }
{hex_const}|{number} { printf("%s - Integer Constant\n",yytext); }
{float_number} { printf("%s - Floating point Constant\n",yytext); }
{arithmetic}[=] { printf("%s - Arithmetic Assignment Operator\n",yytext); }
{logical} { printf("%s - Logical Operator\n",yytext); }
{bitwise} { printf("%s - Bitwise Operator\n",yytext); }
{unary} { printf("%s - Unary Operator\n",yytext); }
{relational} { printf("%s - Relational Operator\n",yytext); }
{arithmetic} { printf("%s - Arithmetic Operator\n",yytext); }
{char_const} { printf("%s - Character Constant\n",yytext); }
{string_const} { printf("%s - String Constant\n",yytext); }
{special} { printf("%s - Special Character\n",yytext); }
%%

int yywrap() {
  return(1);
}

int main(int argc, char* argv[]) {
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	return 0;
}
