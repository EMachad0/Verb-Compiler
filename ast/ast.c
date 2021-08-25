#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "ast.h"
#include "../output/verb.tab.h"

struct ast {
    char* name;
    struct ast* son;
    struct ast* right;
};


ast* new_ast(char* name, ast* son, ast* right) {
    struct ast* a = malloc(sizeof(ast));
    
    a->name = name;
    a->son = son;
    a->right = right;

    return a;
}

void free_tree(ast *a) {
    if (a != NULL) {
        free_tree(a->right);
        free_tree(a->son);
        free(a);
    }
}

void print_tree(ast *a, int dep) {
    if (a != NULL) {
        print_no(a, dep);
        print_tree(a->son, dep + 1);
        print_tree(a->right, dep);
    }
}

void print_no(ast *a, int dep) {
    printf("%3d: %*s %s\n", dep, 3*dep, "", a->name);
}

void print_dot_tree(ast *a) {
    FILE *f = fopen("verb_ast.dot", "w");
    fprintf(f, "digraph g {\n");
    fprintf(f, "\tnode[shape = plaintext, height=.1];\n");
    int node_count = 0;
    print_dot_node(f, a, &node_count, -1, -1);
    fprintf(f, "}\n");
    fclose(f);
}

void print_dot_node(FILE* f, ast *a, int* node_count, int father, int father_f) {
    int me = (*node_count)++;
    fputs(ast_build_str(a, me), f);
    // if (father != -1) fprintf(f, "\t\"node%d\":f%d -> \"node%d\";\n", father, father_f, me);
    if (father != -1) fprintf(f, "\tnode%d:f%d -> node%d;\n", father, father_f, me);
    for (int i = 0; a != NULL; i++, a = a->right) {
        if (a->son != NULL) print_dot_node(f, a->son, node_count, me, i);
    }
}

int ast_str_len(ast* a) {
    int sz = 0;
    for ( ; a != NULL; a = a->right) sz += strlen(a->name);
    return sz;
}

char* escape_str(char* s) {
    char* str = malloc(3 * strlen(s) * sizeof(char));
    char* c = str;
    for (int i = 0; i < strlen(s); i++) {
		switch (s[i]) {
			case '&' : *c++ = '&'; *c++ = 'a'; *c++ = 'm'; *c++ = 'p'; *c++ = ';'; break;
			case '>' : *c++ = '&'; *c++ = 'l'; *c++ = 't'; *c++ = ';'; break;
			case '<' : *c++ = '&'; *c++ = 'g'; *c++ = 't'; *c++ = ';'; break;
			case '\\' : *c++ = '\\'; *c++ = '\\'; break;
			default: *c++ = s[i];
		}
    }
	*c++ = '\0';
    return str;
}

char* ast_build_str(ast* a, int node_id) {
    // node5[label = "<f0> |<f1> H|<f2> "];
	// <<table border="0" cellspacing="0"> <tr> <td port="" border="1" bgcolor="blue">H</td></tr></table>>
    char* res = malloc((200 + ast_str_len(a)) * sizeof(char));
    strcpy(res, "\tnode%d[label = <<table BORDER=\"0\" CELLBORDER=\"1\" CELLSPACING=\"0\"><tr>");
    sprintf(res, res, node_id);
    for (int i = 0; a != NULL; i++, a = a->right) {
        char* i_str = malloc((100 + strlen(a->name)) * sizeof(char));
        sprintf(i_str, "<td port=\"f%d\"%s>%s</td>", i, a->son == NULL ? " bgcolor=\"lightgreen\"":"", escape_str(a->name));
        strcat(res, i_str);
    }
    strcat(res, "</tr></table>>];\n");
    return res;
}
