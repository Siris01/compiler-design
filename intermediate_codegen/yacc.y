%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

int yylex(void);
int yyerror();
#include "y.tab.h"
extern int line;
int error = 0;

struct three_address_code {
	char* op1;
	char* op2;
	char* op;
};

struct three_address_code tac[100];
//memset(tac, 0, sizeof(tac));

int tac_index = 0;

void add_tac(char* op1, char* op2, char* op) {
	tac[tac_index].op1 = (char*)malloc(sizeof(char)*strlen(op1));
	tac[tac_index].op1 = op1;

	tac[tac_index].op2 = (char*)malloc(sizeof(char)*strlen(op2));
	tac[tac_index].op2 = op2;

	tac[tac_index].op = (char*)malloc(sizeof(char)*strlen(op));
	tac[tac_index].op = op;

	tac_index++;
}

char* get_tac_label(int index) {
    int rounds = 0;
    while (index >= pow(26, rounds+1)) {
        index -= pow(26, rounds+1);
        rounds++;
    }

    char* label = (char*)malloc(rounds+2); // create a string to store the label
    int i;
    for (i = 0; i < rounds+2; i++) {
        label[i] = 'A' + (index % 26);
        index /= 26;
    }
    label[rounds+1] = '\0'; // terminate the string with null character

    // reverse the string
    int len = strlen(label);
    char temp;
    for (i = 0; i < len/2; i++) {
        temp = label[i];
        label[i] = label[len-i-1];
        label[len-i-1] = temp;
    }

    return label;
}

void print_tac() {
	int i;

	for(i = 0; i < tac_index; i++) {
		if (tac[i].op == 0) { //Special GOTO case
			printf("GOTO %c\n", tac[i].op1);
		} else {
			printf("%s: %s %s %s\n", get_tac_label(i), tac[i].op1, tac[i].op, tac[i].op2);
		}
	}
}
%}

%start program
%token ID VISIBILITY DATA_TYPE  
%token CHAR STRING NUMBER
%token LOGICAL_OP UNARY_OP BITWISE_OP RELATIONAL_OP ARITHMETIC_OP ARITH_ASSIGN_OP
%token CLASS NEW RETURN STATIC IF ELSE FOR PRINT

%union {
    char *str;
}

%type<str> ARITHMETIC_OP expression
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
	| assignment
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
assignment:
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
	| expression ARITHMETIC_OP expression { printf("%s %s %s", $1, $2, $3); add_tac($1, $3, $2); } ;
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
	printf("\n--- Matched TACs ---\n");
	yyparse();

    if (!error) {
        printf("\n--- Final TAC table ---\n");
		print_tac();
    }
    return 0;
}
