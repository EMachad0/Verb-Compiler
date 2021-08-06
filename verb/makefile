
verb: verb.l verb.y
	bison -d verb.y
	flex -o verb.lex.c verb.l
	cc -o $@ verb.tab.c verb.lex.c verb.c

graph: verb.y
	bison -d -g verb.y
	dot -Tpng verb.dot -o verb.png

counterexamples:
	bison -d verb.y -Wcex 2> cex.output

clean:
	rm *.tab.h *.lex.c *.tab.c *.output *.dot *.png
