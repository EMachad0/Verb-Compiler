# Verb Compilator

Verb is a programming language where all the keywords are only one character. 

### Dependencies 

The envirornment used to develop: **Ubuntu 20.04, gcc 9.3.0, make 4.2.1**

* **Bison: 3.7**
* **Flex: 2.6.4**

### How To Run

* Compile using `make`:
    ```bash
    cd verb
    make
    ```
* Run
    ```bash
    ./verb mycode.ve        # compile mycode.ve 
    ./verb -g mycode.ve     # compile and generates the derivation tree
    ./verb -p mycode.ve     # compile and prints step by step the derivation
    ```

    There are some code examples in tests file. So when run with `-g` the syntax tree will be generated in the `ast.png` file.

## Important Files

All the code of the compiler is in the `verb` directory:

* **ast.c and ast.h**: code for the abstract syntax tree
* **verb.l**: definition of lexical analyser
* **verb.y**: definition of the grammar and of the syntax analyser


