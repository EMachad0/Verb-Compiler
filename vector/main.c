#include <stdio.h>
#include <stdlib.h>
#include "vector.h"

int main(){
    vector* v_int = vector_create();


    for (int i=0; i < 100; i++) {
        vector_pushback_ll(v_int, i);
    }
    
    for (int i=0; i < 100; i++) {
        printf("%lli\n", vector_get_ll(v_int, i));
    }

    for (int i=100; i > 0; i--) {
        vector_set_ll(v_int, i, vector_get_ll(v_int, i) - i);
    }

    for (int i=0; i < 100; i++) {
        printf("%lli\n", vector_get_ll(v_int, i));
    }

    printf("tamanho: %i\n", vector_size(v_int));
    
    vector_delete(v_int);

    vector *v_char = vector_create();

    vector_pushback_char(v_char, "asdf");
    vector_pushback_char(v_char, "bsdf");
    vector_pushback_char(v_char, "csdf");
    vector_pushback_char(v_char, "dsdf");
    vector_pushback_char(v_char, "esdf");
    vector_pushback_char(v_char, "fsdf");
    vector_pushback_char(v_char, "jsdf");
    vector_pushback_char(v_char, "ksdf");
    vector_pushback_char(v_char, "lsdf");
    vector_pushback_char(v_char, "msdf");


    printf("%s\n", (char *) vector_get_char(v_char, 0));
    printf("%s\n", (char *) vector_get_char(v_char, 1));
    printf("%s\n", (char *) vector_get_char(v_char, 2));
    printf("%s\n", (char *) vector_get_char(v_char, 3));
    printf("%s\n", (char *) vector_get_char(v_char, 4));
    printf("%s\n", (char *) vector_get_char(v_char, 5));
    printf("%s\n", (char *) vector_get_char(v_char, 6));
    printf("%s\n", (char *) vector_get_char(v_char, 7));
    printf("%s\n", (char *) vector_get_char(v_char, 8));
    printf("%s\n", (char *) vector_get_char(v_char, 9));


    for (int i=0; i < vector_size(v_char); i++) {
        vector_set_char(v_char, i, "a");
    }

    printf("%s\n", (char *) vector_get_char(v_char, 0));
    printf("%s\n", (char *) vector_get_char(v_char, 1));
    printf("%s\n", (char *) vector_get_char(v_char, 2));
    printf("%s\n", (char *) vector_get_char(v_char, 3));
    printf("%s\n", (char *) vector_get_char(v_char, 4));
    printf("%s\n", (char *) vector_get_char(v_char, 5));
    printf("%s\n", (char *) vector_get_char(v_char, 6));
    printf("%s\n", (char *) vector_get_char(v_char, 7));
    printf("%s\n", (char *) vector_get_char(v_char, 8));
    printf("%s\n", (char *) vector_get_char(v_char, 9));

    vector *empty = vector_create();

    printf("vector char is empty %i\n", vector_empty(v_char));
    printf("empty vector is empty %i\n", vector_empty(empty));

    vector_delete(v_char);
    vector_delete(empty);

}