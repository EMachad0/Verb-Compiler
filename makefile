
all: output_dir bison flex output/verb.tab.c output/verb.lex.c ast/ast.c
	cc -o output/verb output/verb.tab.c output/verb.lex.c ast/ast.c

exec: all
	./output/verb

flex: src/verb.l
	flex -o output/verb.lex.c src/verb.l

bison: src/verb.y
	bison -o output/verb.tab.c -d src/verb.y

counterexamples: src/verb.y
	bison -o output/verb.tab.c -d src/verb.y -Wcex 2> output/cex.output

graph: src/verb.y
	bison -g output/verb.dot -d src/verb.y
	dot -Tpng output/verb.dot -o output/verb.png

output_dir:
	mkdir -p output

clean:
	rm -r output
