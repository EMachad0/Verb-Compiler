#include <stdlib.h>
#include <stdio.h>
#include "hashmap_symbol.h"

int main() {
  
    hashmap *map = hashmap_create(1024);
    
    set_symbol(map, "lorem", 1, 1);
    set_symbol(map, "ipsum", 2, 2);
    set_symbol(map, "dolor", 3, 1);
    set_symbol(map, "sit", 4, 2);
    set_symbol(map, "amet", 5, 1);
    set_symbol(map, "Vaicara", 8, 2);
    set_symbol(map, "A", 1, 1);
    set_symbol(map, "A", 8, 2);
    set_symbol(map, "trintaetres", 33, 1);
    set_symbol(map, "C", 2, 2);
    set_symbol(map, "D", 516, 1);

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

    hashmap_delete(map);
    
    return EXIT_SUCCESS;
}
