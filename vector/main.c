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

    printf("tamanho: %i\n", vector_size(v_int));
    
    free(v_int);

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

    free(v_char);

}