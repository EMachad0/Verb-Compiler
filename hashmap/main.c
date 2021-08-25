#include <stdlib.h>
#include <stdio.h>
#include "hashmap.h"

typedef struct {
    int value;
    int type;
} symbol;

symbol *create_symbol(int value, int type) {
    symbol *res = (symbol *) malloc(sizeof(symbol));
    res->value = value;
    res->type = type;
    return res;
}

symbol *get_symbol(hashmap *map, char* key) {
    return (symbol *) hashmap_get(map, key);
}

int main() {
  
    hashmap *map = hashmap_create(1024);
    
    hashmap_set(map, "lorem", create_symbol(1, 1));
    hashmap_set(map, "ipsum", create_symbol(2, 2));
    hashmap_set(map, "dolor", create_symbol(3, 1));
    hashmap_set(map, "sit", create_symbol(4, 2));
    hashmap_set(map, "amet", create_symbol(5, 1));
    hashmap_set(map, "Vaicara", create_symbol(8, 2));
    hashmap_set(map, "A", create_symbol(1, 1));
    hashmap_set(map, "A", create_symbol(8, 2));
    hashmap_set(map, "trintaetres", create_symbol(33, 1));
    hashmap_set(map, "C", create_symbol(2, 2));
    hashmap_set(map, "D", create_symbol(516, 1));

    printf("map['%s']->value = %i\n", "lorem", get_symbol(map, "lorem")->value);
    printf("map['%s']->type = %i\n", "lorem", get_symbol(map, "lorem")->type);
    
    printf("map['%s']->value = %i\n", "ipsum", get_symbol(map, "ipsum")->value);
    printf("map['%s']->type = %i\n", "ipsum", get_symbol(map, "ipsum")->type);

    printf("map['%s']->value = %i\n", "trintaetres", get_symbol(map, "trintaetres")->value);
    printf("map['%s']->type = %i\n", "trintaetres", get_symbol(map, "trintaetres")->type);

    printf("has('%s') = %i\n", "amet", hashmap_has(map, "amet"));
    printf("has('%s') = %i\n", "pedro", hashmap_has(map, "pedro"));

    printf("size: %i\n", hashmap_size(map));

    hashmap_remove(map, "lorem");
    printf("size: %i\n", hashmap_size(map));
    // hashmap_print(map);

    hashmap_delete(map);
    
    return EXIT_SUCCESS;
}
