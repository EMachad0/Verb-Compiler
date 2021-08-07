#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "verb.h"
#include "verb.tab.h"

struct ast {
    char* name;
    struct ast* son;
    struct ast* dir;
};


ast* new_ast(char* name, ast* son, ast* dir) {
    struct ast* a = malloc(sizeof(ast));
    
    a->name = name;
    a->son = son;
    a->dir = dir;

    return a;
}

void print_tree(ast *a, int dep) {
    if (a != NULL) {
        print_no(a, dep);
        print_tree(a->son, dep + 1);
        print_tree(a->dir, dep);
    }
}

void print_no(ast *a, int dep) {
    printf("%3d: %*s %s\n", dep, 3*dep, "", a->name);
}
