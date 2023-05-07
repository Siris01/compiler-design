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
%token LOGICAL_OP UNARY_OP BITWISE_OP RELATIONAL_OP ARITHMETIC_OP ARITH_ASSIGN_OP
%token CLASS NEW RETURN STATIC IF ELSE FOR PRINT

%union {
    char *str;
}

%type<str> ID VISIBILITY DATA_TYPE  
%type<str> CHAR STRING NUMBER
%type<str> LOGICAL_OP UNARY_OP BITWISE_OP RELATIONAL_OP ARITHMETIC_OP ARITH_ASSIGN_OP
%type<str> CLASS NEW RETURN STATIC IF ELSE FOR PRINT

%type<str> program function_list function parameter_list parameter
%type<str> main_prog statement_list statement declaration assignment 
%type<str> assign_dec_lhs if_statement loop_statement print_statement 
%type<str> expression function_call chain_of_objects expression_list
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
main_prog: statement_list { add_tacs($1); }
statement_list: 
	statement_list statement {
		sprintf(temp, "%s\n%s", $1, $2);
		$$ = strdup(temp);
	}
	| statement_list statement RETURN expression ';'
	| statement {
		$$ = strdup($1);
	}
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
		sprintf(temp, "%s = %s", $2, $4);
		$$ = strdup(temp);
	 }
	| ID assign_dec_lhs ';' // Class
	| ID assign_dec_lhs '=' expression ';' // Class
	;
assignment:
	assign_dec_lhs '=' expression ';' { 
		sprintf(temp, "%s = %s", $1, $3);
		$$ = strdup(temp);
	 };
assign_dec_lhs:
	ID '[' expression ']'
	| ID
	;
if_statement:
	IF '(' expression ')' '{' statement_list '}' ELSE '{' statement_list '}' {		
		sprintf(temp, "if (%s) goto L%dt\ngoto L%df\nL%dt:%s\nL%df:%s", $3, label_index, label_index, label_index, $6, label_index, $10);
		$$ = strdup(temp);
		label_index++;
	}
	| IF '(' expression ')' '{' statement_list '}'
	;
loop_statement:
	FOR '(' declaration expression ';' expression ')' '{' statement_list '}' {
		sprintf(temp, "%s\nL%dl:if (%s) goto L%dt\ngoto L%df\nL%dt: %s\n%s\ngoto L%dl\nL%df: ", $3, label_index, $4, label_index, label_index, label_index, $9, $6, label_index, label_index);
		$$ = strdup(temp);
		label_index++;
	}
print_statement:
	PRINT '(' expression ')' ';'
	| PRINT '(' ')' ';'
expression:
	'(' expression ')'
	| NEW ID '(' expression_list ')'
	| function_call
	| expression LOGICAL_OP expression
	| expression ARITHMETIC_OP expression { 
		sprintf(temp, "%s %s %s", $1, $2, $3);
		$$ = strdup(temp);
	 }
	| expression ARITH_ASSIGN_OP expression
	| expression RELATIONAL_OP expression { 
		sprintf(temp, "%s %s %s", $1, $2, $3);
		$$ = strdup(temp);
	 }
	| expression BITWISE_OP expression
	| UNARY_OP expression
	| expression UNARY_OP {
		if (strcmp($2, "++") == 0) {
			sprintf(temp, "%s = %s + 1", $1, $1);
			$$ = strdup(temp);
		}
	}
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
	temp =  (char*) malloc(sizeof(char) * TEMP_SIZE);
	yyparse();

    if (!error) {
        printf("\n--- TAC ---\n");
		for(int i = 0; i < tac_index; i++) {
			printf("%s\n", tac[i]);
		}
    }
    return 0;
}
