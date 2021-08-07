
all: verb.l verb.y verb.c
	bison -d verb.y
	flex -o verb.lex.c verb.l
	cc -o verb verb.tab.c verb.lex.c verb.c

compile-with-debug: verb.l verb.y
	bison -d verb.y
	flex -o verb.lex.c verb.l
	gcc -o $@ verb.tab.c verb.lex.c verb.c -g

graph: verb.y
	bison -d -g verb.y
	dot -Tpng verb.dot -o verb.png

counterexamples:
	bison -d verb.y -Wcex 2> cex.output

clean:
	rm *.tab.h *.lex.c *.tab.c *.output *.dot *.png
