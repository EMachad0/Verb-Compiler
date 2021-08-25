#ifndef AVLTREE_H
#define AVLTREE_H

#include <stdbool.h>

typedef struct avltree avltree;

avltree *avltree_create(void);
void avltree_delete(avltree *);

void avltree_insert(avltree *, const char *, void *);
void avltree_remove(avltree *, const char *);
void *avltree_get(avltree *, const char *);

int avltree_height(avltree *);
int avltree_size(avltree *);

bool avltree_has(avltree *, const char *);

#endif