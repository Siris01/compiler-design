%{
#include <stdio.h>
%}

keyword auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while

arith \+|\-|\*|\%
spl ;|,|\.|\[\]|\(\)|\{\}

%%
{keyword} { printf("%s\t\t-\t\tKeyword\n", yytext); }
{arith} { printf("%s\t\t-\t\tArithmetic operator\n", yytext); }
{spl} { printf("%s\t\t-\t\tSpecial character\n", yytext); }
= { printf("%s\t\t-\t\tAssignment operator\n", yytext); }
[a-zA-Z][_a-zA-z0-9]* { printf("%s\t\t-\t\tIdentifier\n", yytext); }
\/\/.* { printf("%s\t\t-\t\tSingle line comment\n", yytext); }
\/\*.*\*\/ { printf("%s\t\t-\t\tMulti line comment\n", yytext); }
[0-9] { printf("%s\t\t-\t\tInteger constant\n", yytext); }
\"[^\n"]+\" { printf("%s\t\t-\t\tString constant\n", yytext); }

\n {}
%%
int main(int argc, char* argv[]) {
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	return 0;
}
