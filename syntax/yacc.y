%{
#include <stdlib.h>
#include <stdio.h>

int yylex(void);
int yyerror();
#include "y.tab.h"
extern int line;
int error = 0;
%}

%start program
%token ID VISIBILITY DATA_TYPE  
%token CHAR STRING NUMBER
%token LOGICAL_OP UNARY_OP BITWISE_OP RELATIONAL_OP ARITHMETIC_OP ARITH_ASSIGN_OP
%token CLASS NEW RETURN STATIC IF ELSE FOR PRINT

%%
program: 
	CLASS ID '{' function_list '}';
function_list: 
	function_list function
	| function
	| /* empty */
	;
function: 
	VISIBILITY STATIC DATA_TYPE ID '(' parameter_list ')' '{' statement_list '}'
	| STATIC DATA_TYPE ID '(' parameter_list ')' '{' statement_list '}'
	| VISIBILITY DATA_TYPE ID '(' parameter_list ')' '{' statement_list '}'
	| DATA_TYPE ID '(' parameter_list ')' '{' statement_list '}'
parameter_list: 
	parameter_list ',' parameter
	| parameter
	| /* empty */
	;
parameter: 
	DATA_TYPE ID
	| DATA_TYPE ID '[' ']'
statement_list: 
	statement_list statement
	| statement_list statement RETURN expression ';'
	| statement
	| /* empty */
	;
statement: 
	declaration
	| assignemnt
	| if_statement
	| loop_statement
	| print_statement
	| function_call ';'
	;
declaration: 
	DATA_TYPE assign_dec_lhs ';'
	| DATA_TYPE assign_dec_lhs '=' expression ';'
	| ID assign_dec_lhs ';' // Class
	| ID assign_dec_lhs '=' expression ';' // Class
	;
assignemnt:
	assign_dec_lhs '=' expression ';'
	| assign_dec_lhs '=' ID ';'
	| assign_dec_lhs '=' NUMBER ';'
	| assign_dec_lhs '=' CHAR ';'
	| assign_dec_lhs '=' STRING ';'
	;
assign_dec_lhs:
	ID '[' expression ']'
	| ID
	;
if_statement:
	IF '(' expression ')' '{' statement_list '}' ELSE '{' statement_list '}'
	| IF '(' expression ')' '{' statement_list '}' ELSE '{' '}'
	| IF '(' expression ')' '{' statement_list '}' ELSE statement
	| IF '(' expression ')' '{' statement_list '}'
	| IF '(' expression ')' statement ELSE '{' statement_list '}'
	| IF '(' expression ')' statement ELSE '{' '}'
	| IF '(' expression ')' statement ELSE statement
	| IF '(' expression ')' statement
	;
loop_statement:
	FOR '(' DATA_TYPE ID '=' expression ';' expression ';' expression ')' '{' statement_list '}'
	| FOR '(' DATA_TYPE ID '=' expression ';' expression ';' expression ')' statement
print_statement:
	PRINT '(' expression ')' ';'
	| PRINT '(' ')' ';'
expression:
	'(' expression ')'
	| NEW ID '(' expression_list ')'
	| function_call
	| expression LOGICAL_OP expression
	| expression ARITHMETIC_OP expression
	| expression ARITH_ASSIGN_OP expression
	| expression RELATIONAL_OP expression
	| expression BITWISE_OP expression
	| UNARY_OP expression
	| expression UNARY_OP
	| ID '[' expression ']'
	| '{' expression_list '}'
	| ID '.' ID
	| NUMBER
	| ID
	| CHAR
	| STRING
	| /* empty */
	;
function_call:
	ID '(' expression_list ')'
	| chain_of_objects '(' expression_list ')';
chain_of_objects:
	chain_of_objects '.' ID
	| ID
	| /* empty */
	;
expression_list:
	expression_list ',' expression
	| expression
	| /* empty */
	;
%%

int yyerror(){
    fprintf(stderr, "---\nSyntax is NOT valid!\nError around line %d\n", line);
    error = 1;
    return 0;
}

int yywrap() {
	return 1;
}

int main(void) {
	yyparse();

    if(!error){
        printf("---\nValid syntax!\n");
    }
    return 0;
}
