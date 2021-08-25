#include <stdlib.h>
#include <stdio.h>
#include "vector.h"

struct vector
{
    void **buffer;
    int size;
    int capacity;
};

vector* vector_create(){
    vector* res = malloc(sizeof(vector));
    
    const int cap = 256;
    res->buffer = malloc(sizeof(void *)*cap);
    res->size = 0;
    res->capacity = cap;

    return res;
}

void vector_delete(vector* vector){
    free(vector->buffer);
    free(vector);
}

void vector_pushback_char(vector *v, char *s) {
    vector_pushback(v, s);
}

void vector_pushback_ll(vector *v, long long value) {
    vector_pushback(v, (void *) value);
}

void vector_pushback(vector* vector, void *value){
    vector->buffer[vector->size] = value;
    vector->size++;
    if (vector->size >= vector->capacity) {
        void **old = vector->buffer;

        vector->capacity *= 2;
        vector->buffer = (void **) malloc(sizeof(void *) * vector->capacity);

        for (int i=0; i<vector->size; i++) vector->buffer[i] = old[i];
    }
}

void *vector_get(vector* vector, int i){
    if (i >= vector->size) {
        fprintf(stderr, "NullPointerException\n");
        return 0;
    } 
    return vector->buffer[i];
}

char *vector_get_char(vector *vector, int i) {
    if (i >= vector->size) {
        fprintf(stderr, "NullPointerException\n");
        return "erro";
    }
    return (char *) vector_get(vector, i);
}

long long vector_get_ll(vector *vector, int i) {
    return (long long) vector_get(vector, i);
}

void *vector_pop(vector* vector){
    return vector->buffer[vector->size--];
}

int vector_size(vector* vector){
    return vector->size;
}
