lex lex.l
yacc -d yacc.y
gcc y.tab.c lex.yy.c -lm
chmod +x a.out
./a.out < $1