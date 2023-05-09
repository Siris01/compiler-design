clear
rm a.out
lex lex.l
yacc -Wnone -d yacc.y
gcc y.tab.c lex.yy.c -lm
printf "Tokens: \n\n"
./a.out < $1

printf "\n\n---Code optimizer\n"
gcc optimize.c -o optimize.o
./optimize.o out.tac dead

printf "\n\n---Codegen\n"
gcc codegen.c -o codegen.o
./codegen.o out_optimized.tac