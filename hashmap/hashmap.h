#ifndef HASHMAP_H
#define HASHMAP_H

#include <stdbool.h>

typedef struct hashmap hashmap;

hashmap *hashmap_create(int capacity);

void hashmap_set(hashmap *map, const char *key, void *);

void *hashmap_get(hashmap *map, const char *key);

bool hashmap_has(hashmap *map, const char *key);

void hashmap_remove(hashmap *map, const char *key);

int hashmap_size(hashmap *map);

void hashmap_delete(hashmap *map);

// void hashmap_print(hashmap *map);

unsigned long elf_hash(const char *);

#endif