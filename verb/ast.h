/* interface to the lexer */
// extern int yylineno; /* from lexer */

#ifndef VERB_H
#define VERB_H

typedef struct ast ast;

ast* new_ast(char*, ast*, ast*);
void free_tree(ast *);
void print_tree(ast*, int);
void print_no(ast*, int);
void print_dot_tree(ast *);
void print_dot_node(FILE* , ast *, int*, int , int );
int ast_str_len(ast* );
char* ast_build_str(ast*, int);
char* escape_str(char* );

#endif
