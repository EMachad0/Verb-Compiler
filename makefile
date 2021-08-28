
all: compile run

compile: output_dir bison flex output/verb.tab.c output/verb.lex.c
	cc -o output/verb output/verb.tab.c output/verb.lex.c hashmap/avltree.c hashmap/hashmap.c hashmap/hashmap_symbol.c vector/vector.c utils/str_utils.c src/jasmin.c

run:
	output/verb $(f)
	java -jar ./jasmin-2.4/jasmin.jar -g ./output/verb.j
	java output.Verb

flex: src/verb.l
	flex -o output/verb.lex.c src/verb.l

bison: src/verb.y
	bison -o output/verb.tab.c -d src/verb.y

counterexamples: src/verb.y
	bison -o output/verb.tab.c -d src/verb.y -Wcex 2> output/cex.output

graph: src/verb.y
	bison -o output/verb.tab.c --graph=output/verb.dot -d src/verb.y
	dot -Tpng output/verb.dot -o output/verb.png

output_dir:
	mkdir -p output

help:
	@echo "Verb-Compiler - https://github.com/EMachad0/Verb-Compilator\n\n"
	@echo "To this compiler try the command:\n" 
	@echo " 		make f=tests/<any-file>.ve\n"
	@echo "OTHER COMMADS:\n"
	@echo "		make                   Only compiles and expects the input"
	@echo "		make f=<code>.ve       Compiles and runs the code in <code>.ve file in JVM"
	@echo "		make compile           Only compile all the code to the ./output directory"
	@echo "		make run f=<code>.ve   Runs the <code>.ve in JVM"
	@echo "		make flex              Compile only the flex file src/verb.l"
	@echo "		make bison             Compile only the byson file src/verb.y"
	@echo "		make graph             Creates the automata for the syntax defined in src/verb.y\n"
	@echo "Made by:"
	@echo "           Eliton Machado  https://github.com/EMachad0"
	@echo "           Igor Froehner   https://github.com/IgorFroehner"

clean:
	rm -r output
