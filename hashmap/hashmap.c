#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "hashmap.h"
#include "avltree.h"

struct hashmap{
    avltree **buffer;
    int capacity;
};

// Uma funcao para criar uma tabela vazia na memória. Essa função irá receber um inteiro como argumento, 
// que será a quantidade de buckets desejados dentro da tabela hash. 
// A função deve retornar NULL caso o número seja menor que um.
hashmap *hashmap_create(int capacity){
    if (capacity<1) return NULL;
    
    hashmap *res = malloc(sizeof(hashmap));
    res->buffer = malloc(sizeof(avltree *) * capacity);
    res->capacity = capacity;
    
    return res;
}

// Uma função para inserir valores dentro da tabela. Essa função irá receber como argumentos a tabela desejada, a chave desejada, e o valor a ser salvo.
// A função deverá encontrar o bucket correto para a chave, e inserir o valor (ou atualizá-lo, caso o valor já exista no bucket). 
void hashmap_set(hashmap *map, const char *key, void *value){
    int index = elf_hash(key) % map->capacity;

    if (map->buffer[index]==NULL){
        map->buffer[index] = avltree_create();
    }

    avltree_insert(map->buffer[index], key, value);
}

// Uma função para procurar o valor de uma chave dentro da tabela. Essa função irá receber como argumentos a tabela desejada e a chave desejada. 
// Caso a chave não exista dentro da tabela, a função deve retornar zero.
void *hashmap_get(hashmap *map, const char *key){
    int index = elf_hash(key)%map->capacity;

    if (map->buffer[index]!=NULL){
        return avltree_get(map->buffer[index], key);
    }

    fprintf(stderr, "key does not exist\n");
    return 0;
}

// Uma função para verificar se uma chave existe dentro da tabela. Essa função irá receber como argumentos a tabela desejada e a chave desejada. 
// Caso a tabela contenha um valor para a chave informada, a função deve retornar 1 (verdadeiro). 
// Caso a tabela não contenha um valor para a chave, a função deve retornar 0 (falso).
bool hashmap_has(hashmap *map, const char *key){
    int index = elf_hash(key)%map->capacity;

    if (map->buffer[index]!=NULL){
        return avltree_has(map->buffer[index], key);
    }
}

// Uma função que remove uma chave e seu valor da tabela. Essa função irá receber como argumentos a tabela desejada e a chave desejada. 
// Caso a tabela contenha um valor para aquela chave, o valor deve ser removido. 
// Caso a tabela não contenha um valor para aquela chave, nada precisa ser feito. 
void hashmap_remove(hashmap *map, const char *key){
    int index = elf_hash(key)%map->capacity;
    
    if (map->buffer[index]!=NULL){
        avltree_remove(map->buffer[index], key);
    }
}

// Uma função que retorna a quantidade de itens (pares de chave e valor) existentes em uma tabela. Seu único argumento é a tabela desejada.
int hashmap_size(hashmap *map){
    int cont=0;
    for (int i=0; i<map->capacity; i++){
        if (map->buffer[i]!=NULL){
            cont += avltree_size(map->buffer[i]);
        }
    }
    return cont;
}

// Finalmente, uma função para limpar a memória de uma tabela. Seu único argumento é a tabela a ser deletada. 
// Todos os buckets dentro da tabela precisam ser liberados também.
void hashmap_delete(hashmap *map){
    for (int i=0; i<map->capacity; i++){
        if (map->buffer[i]!=NULL){
            avltree_delete(map->buffer[i]);
        }
    }
    free(map->buffer);
    free(map);
}

// // Printa o hashmap.
// void hashmap_print(hashmap *map){
//     for (int i=0; i<map->capacity; i++)
//         if (map->buffer[i]!=NULL)
//             avltree_print(map->buffer[i]);
// }

/**
 * Função padronizada para calcular o hash de uma string.
 */
unsigned long elf_hash(const char *s) {
    unsigned long h = 0;
    for(int i = 0; i < strlen(s); i++) {
        h = (h << 4) + s[i];
        unsigned long x = h & 0xF0000000;
        if(x != 0) {
            h ^= x >> 24;
            h &= ~x;
        }
    }

    return h;
}
