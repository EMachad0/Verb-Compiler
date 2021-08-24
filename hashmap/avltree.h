#ifndef AVLTREE_H
#define AVLTREE_H

#include <stdbool.h>

typedef struct avltree avltree;

avltree *avltree_create(void);
void avltree_delete(avltree *);

void avltree_insert(avltree *, const char *, int);
void avltree_remove(avltree *, const char *);
int avltree_get(avltree *, const char *);

int avltree_height(avltree *);
int avltree_size(avltree *);

void avltree_print(avltree *);

bool avltree_has(avltree *, const char *);

void avltree_inorder(avltree *, void (*f)(const char *, int));
void avltree_postorder(avltree *, void (*f)(const char *, int));
void avltree_preorder(avltree *, void (*f)(const char *, int));

#endif