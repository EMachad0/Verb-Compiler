#include "hashmap_symbol.h"
#include <stdlib.h>

void *set_symbol(hashmap *map, const char *key, int lid, int type) {
    hashmap_set(map, key, (void *) make_symbol(key, lid, type));
}

symbol *get_symbol(hashmap *map, const char *key) {
    return (symbol *) hashmap_get(map, key);
}

symbol *make_symbol(const char *id, int lid, int type) {
    symbol *res = (symbol *) malloc(sizeof(symbol));
    res->id = id;
    res->lid = lid;
    res->type = type;
    return res;
}
