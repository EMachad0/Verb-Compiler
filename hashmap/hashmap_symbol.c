#include "hashmap_symbol.h"
#include <stdlib.h>

struct symbol {
    int value;
    int type;
};

void *set_symbol(hashmap *map, const char *key, int value, int type) {
    symbol *res = (symbol *) malloc(sizeof(symbol));
    res->value = value;
    res->type = type;

    hashmap_set(map, key, (void *) res);
}

symbol *get_symbol(hashmap *map, const char *key) {
    return (symbol *) hashmap_get(map, key);
}