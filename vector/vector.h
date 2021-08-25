#ifndef VECTOR_H
#define VECTOR_H

typedef struct vector vector;

vector* vector_create(void);
void vector_delete(vector*);

void vector_pushback(vector*, void*);

void *vector_get(vector*, int);

void *vector_pop(vector*);

int vector_size(vector*);

#endif