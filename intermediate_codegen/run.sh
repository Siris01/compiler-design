rm ./a.out
lex lex.l
yacc -Wnone -d yacc.y
gcc y.tab.c lex.yy.c -lm
chmod +x a.out
./a.out < $1