#include <stdlib.h>
#include <stdio.h>
#include "hashmap.h"

int main() {
  
    hashmap *map = hashmap_create(1024);
    
    hashmap_set(map, "lorem", 1);
    hashmap_set(map, "ipsum", 2);
    hashmap_set(map, "dolor", 3);
    hashmap_set(map, "sit", 4);
    hashmap_set(map, "amet", 5);
    hashmap_set(map, "Vaicara", 5);
    hashmap_set(map, "A", 5);
    hashmap_set(map, "A", 15);
    hashmap_set(map, "B", 5);
    hashmap_set(map, "C", 5);
    hashmap_set(map, "D", 5);


    printf("map['%s'] = %i\n", "lorem", hashmap_get(map, "lorem"));
    printf("map['%s'] = %i\n", "ipsum", hashmap_get(map, "ipsum"));
    printf("map['%s'] = %i\n", "amet", hashmap_get(map, "amet"));

    printf("has('%s') = %i\n", "amet", hashmap_has(map, "amet"));
    printf("has('%s') = %i\n", "pedro", hashmap_has(map, "pedro"));

    printf("size: %i\n", hashmap_size(map));

    printf("hashmap print:\n");
    hashmap_print(map);

    hashmap_remove(map, "lorem");
    printf("size: %i\n", hashmap_size(map));
    hashmap_print(map);

    hashmap_delete(map);
    
    return EXIT_SUCCESS;
}
