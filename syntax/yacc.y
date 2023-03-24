%{
#include <stdlib.h>
#include <stdio.h>

int yylex(void);
void yyerror(char* s);
#include "y.tab.h"
%}

%start program
%token ID NUMBER LOGICAL_OP BITWISE_OP RELATIONAL_OP ARITHMETIC_OP CHAR STRING SPL

%%
program: line "\n" program | line
line: assign | cond | loop | dec
assign:  

%%

void yyerror(char *s) {
	fprintf(stderr,"%s\n",s);
	return;
}

yywrap() {
	return(1);
}

int main(void) {
	yyparse();
	return 0;
}
