
all: compiler run

compiler: output_dir bison flex output/verb.tab.c output/verb.lex.c
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
	@echo "To try this compiler use the command:\n"
	@echo " 		make f=tests/<verb-file>.ve\n"
	@echo "OTHER COMMANDS:\n"
	@echo "		make f=<verb-file>.ve     -- Main way for running this project"
	@echo "		                             Create the compiler, compiles and runs the file"
	@echo "		make compiler             -- Outputs the compiler binary to ./output/verb"
	@echo "		make run f=<verb-file>.ve -- Compile and runs <verb-file>.ve in JVM"
	@echo "		make graph                -- Creates the automata for the syntax defined in src/verb.y"
	@echo "		                             Takes a while\n"
	@echo "Made by:"
	@echo "           Eliton Machado  https://github.com/EMachad0"
	@echo "           Igor Froehner   https://github.com/IgorFroehner"

clean:
	rm -r output
