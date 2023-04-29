%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#define MAX_TACS 1024

int yylex(void);
int yyerror();
extern int line;
int error = 0;

char* tac[MAX_TACS];
int tac_index = 0;
int temp_index = 1;
int label_index = 1;

char* temp;

void add_tac(char* str) {
	tac[tac_index] = (char*) malloc(sizeof(char) * strlen(str));
	strcpy(tac[tac_index], str);
	tac_index++;
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

%type<str> expression statement_list assign_dec_lhs assignment RELATIONAL_OP ARITHMETIC_OP NUMBER
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
	| DATA_TYPE assign_dec_lhs '=' expression ';' { 
		sprintf(temp, "%s = t%d", $2, temp_index-1);
		add_tac(temp);
	 }
	| ID assign_dec_lhs ';' // Class
	| ID assign_dec_lhs '=' expression ';' // Class
	;
assignment:
	assign_dec_lhs '=' expression ';'
	| assign_dec_lhs '=' ID ';'
	| assign_dec_lhs '=' NUMBER ';' { 
		sprintf(temp, "t%d = %s", temp_index, $3);
		add_tac(temp);
		temp_index++;
	 }
	| assign_dec_lhs '=' CHAR ';'
	| assign_dec_lhs '=' STRING ';'
	;
assign_dec_lhs:
	ID '[' expression ']'
	| ID
	;
if_statement:
	IF '(' expression ')' '{' statement_list '}' ELSE '{' statement_list '}' { 
		sprintf(temp, "if (%s) goto L%d", $3, label_index); // If cond
		add_tac(temp);

		sprintf(temp, "goto L%d", label_index + 1); // not(If cond)
		add_tac(temp);

		sprintf(temp, "L%d:\n%s", label_index, $6); // If body
		add_tac(temp);
		label_index++;

		sprintf(temp, "L%d:\n%s", label_index, $10); // Else body
		add_tac(temp);
		label_index++;

	}
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
	| expression ARITHMETIC_OP expression { 
		sprintf(temp, "t%d = %s %s %s", temp_index, $1, $2, $3);
		add_tac(temp);
		temp_index++;
	 }
	| expression ARITH_ASSIGN_OP expression
	| expression RELATIONAL_OP expression { 
		sprintf(temp, "t%d = %s %s %s", temp_index, $1, $2, $3);
		add_tac(temp);
		temp_index++;
	 }
	| expression BITWISE_OP expression
	| UNARY_OP expression
	| expression UNARY_OP
	| ID '[' expression ']'
	| '{' expression_list '}'
	| ID '.' ID
	| NUMBER { 
		sprintf(temp, "t%d = %s", temp_index, $1);
		add_tac(temp);
		temp_index++;
	 }
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
	temp =  (char*) malloc(sizeof(char) * 100);
	yyparse();

    if (!error) {
        printf("\n--- TAC ---\n");
		for(int i = 0; i < tac_index; i++) {
			printf("%s\n", tac[i]);
		}
    }
    return 0;
}
