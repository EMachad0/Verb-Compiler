#ifndef VECTOR_H
#define VECTOR_H

typedef struct vector vector;

vector* vector_create(void);
void vector_delete(vector *);

void vector_pushback(vector *, void *);

void vector_set(vector *, int , void *);

void vector_set_char(vector *, int , char *);
void vector_set_ll(vector *, int , long long );

void vector_pushback_char(vector *, char *);
void vector_pushback_ll(vector *, long long );

void *vector_get(vector *, int);
char *vector_get_char(vector *, int );
long long vector_get_ll(vector *, int );

void *vector_pop(vector*);

int vector_size(vector*);

#endif