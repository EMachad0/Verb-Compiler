
#ifndef HASHMAP_SYMBOL_H
#define HASHMAP_SYMBOL_H

#include "hashmap.h"

typedef struct  {
    int value;
    int type;
} symbol;

void *set_symbol(hashmap *, const char *, int , int );

symbol *get_symbol(hashmap *, const char *);

#endif
