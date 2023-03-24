lex lex.l
yacc -d yacc.y
gcc y.tab.c lex.yy.c
chmod +x a.out
./a.out < $1
