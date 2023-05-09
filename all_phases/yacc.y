%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#define MAX_TACS 1024
#define TEMP_SIZE 1024000

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

void add_tacs(char* str) {
	char* token = strtok(str, "\n");
	while(token != NULL) {
		add_tac(token);
		token = strtok(NULL, "\n");
	}
}
%}

%start program
%token ID VISIBILITY DATA_TYPE  
%token CHAR STRING NUMBER
%token LOGICAL_OP UNARY_OP BITWISE_OP ARITHMETIC_OP ARITH_ASSIGN_OP
%token CLASS NEW RETURN STATIC 

%union {
    char *str;
}

%type<str> ARITHMETIC_OP
%type<str> program function_list function parameter_list parameter
%type<str> main_prog statement_list statement declaration assignment 
%type<str> assign_dec_lhs 
%type<str> expression chain_of_objects expression_list
%%

program: 
	CLASS ID '{' function_list '}';
function_list: 
	function_list function
	| function
	| /* empty */
	;
function: 
	VISIBILITY STATIC DATA_TYPE ID '(' parameter_list ')' '{' main_prog '}'
	| STATIC DATA_TYPE ID '(' parameter_list ')' '{' main_prog '}'
	| VISIBILITY DATA_TYPE ID '(' parameter_list ')' '{' main_prog '}'
	| DATA_TYPE ID '(' parameter_list ')' '{' main_prog '}'
parameter_list: 
	parameter_list ',' parameter
	| parameter
	| /* empty */
	;
parameter: 
	DATA_TYPE ID
	| DATA_TYPE ID '[' ']'
main_prog: statement_list
statement_list: 
	statement_list statement 
	| statement_list statement RETURN expression ';'
	| statement 
	| /* empty */
	;
statement: 
	declaration
	| assignment
	;
declaration: 
	DATA_TYPE assign_dec_lhs ';'
	| DATA_TYPE assign_dec_lhs '=' expression ';' { 
		sprintf(temp, "%s = %s", $2, $4);
		add_tac(temp);
	 }
	| ID assign_dec_lhs ';' // Class
	| ID assign_dec_lhs '=' expression ';' // Class
	;
assignment:
	assign_dec_lhs '=' expression ';' { 
		sprintf(temp, "%s = %s", $1, $3);
		add_tac(temp);
	 }
assign_dec_lhs:
	ID '[' expression ']'
	| ID
	;
expression:
	'(' expression ')'
	| NEW ID '(' expression_list ')'
	| expression LOGICAL_OP expression
	| expression ARITHMETIC_OP expression { 
		sprintf(temp, "t%d = %s %s %s", temp_index, $1, $2, $3);
		add_tac(temp);

		$$ = (char*) malloc(sizeof(char) * 10);
		sprintf($$, "t%d", temp_index);
		
		temp_index++;
	 }
	| expression BITWISE_OP expression
	| UNARY_OP expression
	| expression UNARY_OP
	| ID '[' expression ']'
	| '{' expression_list '}'
	| ID '.' ID
	| NUMBER 
	| '-' NUMBER
	| ID
	| CHAR
	| STRING
	| /* empty */
	;
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
	temp =  (char*) malloc(sizeof(char) * TEMP_SIZE);
	yyparse();

    if (!error) {
		printf("\nSyntax is valid!!\n");
        printf("\n--- TAC ---\n");
		for(int i = 0; i < tac_index; i++) {
			printf("%s\n", tac[i]);
		}

		printf("\n --- Saving TACs to out.tac ---\n");
		FILE *fp;
		fp = fopen("out.tac", "w");
		for(int i = 0; i < tac_index; i++) {
			fprintf(fp, "%s\n", tac[i]);
		}
		fclose(fp);
    }
    return 0;
}
