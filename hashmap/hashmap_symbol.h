
#ifndef HASHMAP_SYMBOL_H
#define HASHMAP_SYMBOL_H

#include "hashmap.h"

typedef struct symbol {
    const char* id;
    int lid;
    int type;
} symbol;

void *set_symbol(hashmap *, const char *, int , int );

symbol *get_symbol(hashmap *, const char *);

symbol *make_symbol(const char *, int , int );

#endif
