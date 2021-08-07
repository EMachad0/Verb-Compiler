/* interface to the lexer */
// extern int yylineno; /* from lexer */

#ifndef VERB_H
#define VERB_H

typedef struct ast ast;

ast* new_ast(char*, ast*, ast*);
void print_tree(ast*, int);
void print_no(ast*, int);

#endif
