#include "avltree.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define max(X, Y)  ((X) > (Y) ? (X) : (Y))
#define min(X, Y)  ((X) < (Y) ? (X) : (Y))

typedef struct node {
    char *key;
    int value;

    int height;
    struct node *left;
    struct node *right;
} node;

struct avltree {
    node *root;
};

// ------------create-----------------

avltree *avltree_create(void){
    avltree *t = malloc(sizeof(avltree));
    t->root = NULL;
    return t;
}

// ----------delete------------------

static void node_delete(node *n){
    if (n->left!=NULL) node_delete(n->left);
    if (n->right!=NULL) node_delete(n->right);
    free(n);
}

void avltree_delete(avltree *t){
    if (t->root) node_delete(t->root);
    free(t);
}

// ------------- HEIGHT

static int node_height(node *n){
    if (n==NULL) return 0;
    return n->height;
}

static int node_factor(node *n) {
    return node_height(n->left) - node_height(n->right);
}

int avltree_height(avltree *t){
    return node_height(t->root);
}

// -------------- INSERT ---------------

static node *left_rotate(node *n){
    node *b = n->right;
    node *y = b->left;

    b->left = n;
    n->right = y;

    n->height = max(node_height(n->left), node_height(n->right))+1;
    b->height = max(node_height(b->left), node_height(b->right))+1;

    return b;
}

static node *right_rotate(node *n) {
    node *b = n->left;
    node *y = b->right;

    b->right = n;
    n->left = y;

    n->height = max(node_height(n->left), node_height(n->right))+1;
    b->height = max(node_height(b->left), node_height(b->right))+1;

    return b;
}

static node *node_insert(node *n, const char *k, int v){
    if (n!=NULL){
        // vê se o cara que a gente tá já não é a chave que estamos procurando
        int compare = strcmp(n->key, k);

        if (compare==0){
            n->value = v;
            return n;
        }

        // se for menor vamos pra esquerda se não vamos pra direita
        if (compare>0){
            n->left = node_insert(n->left, k,  v);
        } else {
            n->right = node_insert(n->right, k, v);
        }

        int factor = node_height(n->left) - node_height(n->right);

        n->height = max(node_height(n->right), node_height(n->left))+1;

        if (factor < -1){
            if (strcmp(k, n->right->key) > 0)
                n = left_rotate(n);
            else{
                n->right = right_rotate(n->right);
                n = left_rotate(n);
            }
        }else
        if (factor > 1){
            if (strcmp(k, n->right->key) > 0){
                n->left = left_rotate(n->left);
                n = right_rotate(n);
            }else
                n = right_rotate(n);
        }

        return n;
    } else{
        // se chegamos em uma parte em que não existe nodo é aqui que ele vai
        n = malloc(sizeof(node));
        n->key = malloc(strlen(k) + 1);
        strcpy(n->key, k);
        n->left = NULL;
        n->right = NULL;
        n->value = v;
        n->height = 1;
        return n;
    }
}

void avltree_insert(avltree *t, const char *k, int v){
    t->root = node_insert(t->root, k, v);
}

// -------------GET-------------

static int node_get(node *n, const char *k) {
    if(n != NULL) {
        int val = strcmp(n->key, k);

        if(val == 0) {
            return n->value;
        }
        if(val > 0) {
            return node_get(n->left, k);
        } else {
            return node_get(n->right, k);
        }
    }
    return 0;
}

int avltree_get(avltree *t, const char *k) {
    return node_get(t->root, k);
}

// -------------REMOVE----------

static node *min_node(node *n){
    node *i = n;
    while(i->left!=NULL)
        i = n->left;
    return i;
}

static node *node_remove(node *n, const char *k){
    if (n==NULL) return n;

    int compare = strcmp(n->key, k);

    if (compare < 0){
        n->left = node_remove(n->left, k);
    }else
    if (compare > 0){
        n->left = node_remove(n, k);
    }else{
        // tamo no nodo pra ser deletado

        // sem filho
        if ((n->left==NULL) || (n->right==NULL)){
            node *aux = n->left!=NULL ? n->left : n->right;
            
            if (aux==NULL){
                node_delete(n);
                n = NULL;
            }else{
                free(n->key);

                *n = *aux;
                free(aux);
            }
        } else {
            // menor cara na direita
            node *temp = min_node(n->right);

            free(n->key);
            n->key = malloc(strlen(temp->key)+1);
            strcpy(n->key, temp->key);
            n->value = temp->value;

            n->right = node_remove(n->right, temp->key);
        }
    }
    // Se não foi ESSE nó que removemos, podemos precisar balancear!
    if(n != NULL) {
        // Podemos ter desbalanceado, então verificamos os fatores!
        int factor = node_height(n->left) - node_height(n->right);

        if(factor < -1) {
            // Pendendo pra direita!
            if(node_factor(n->right) <= 0) {
                // Caso A: right right!
                n = left_rotate(n);
            } else {
                // Caso B: right left!
                n->right = right_rotate(n->right);
                n = left_rotate(n);
            }
        } else if(factor > 1) {
            // Pendendo pra esquerda!
            if(node_factor(n->left) < 0) {
                // Caso C: left right!
                n->left = left_rotate(n->left);
                n = right_rotate(n);
            } else {
                // Caso D: left left!
                n = right_rotate(n);
            }
        }
    }
    return n;
}

void avltree_remove(avltree *t, const char *k){
    t->root = node_remove(t->root, k);
}

// ------------- SIZE ---------

static int node_size(node *n){
    if (n==NULL) return 0;
    return node_size(n->left)+node_size(n->right)+1;
}

int avltree_size(avltree *t){
    if (t->root!=NULL)
        return node_size(t->root);
    return 0;
}

// ------------ HAS -------------

bool avltree_has(avltree *t, const char *k){
    node *it = t->root;
    while (it!=NULL){
        int compare = strcmp(it->key, k);
        if (compare==0) return true;
        if (compare > 0) it = it->left;
        else it = it->right;
    }
    return false;
}


// ----------- INORDER ---------------
 
static void node_inorder(node *n, void (*f)(const char *, int)){
    if (n!=NULL){
        node_inorder(n->left, f);
        f(n->key, n->value);
        node_inorder(n->right, f);
    }
}

void avltree_inorder(avltree *t, void (*f)(const char *, int)){
    node_inorder(t->root, f);
}

// ------------ POSTORDER ---------------

static void node_postorder(node *n, void (*f)(const char *, int)){
    if (n!=NULL){
        node_postorder(n->left, f);
        node_postorder(n->right, f);
        f(n->key, n->value);
    }
}

void avltree_postorder(avltree *t, void (*f)(const char *, int)){
    node_postorder(t->root, f);
}

// ------------ PREORDER ----------------

static void node_preorder(node *n, void (*f)(const char *, int)){
    if (n!=NULL){
        f(n->key, n->value);
        node_preorder(n->left, f);
        node_postorder(n->right, f);
    }
}

void avltree_preorder(avltree *t, void (*f)(const char *, int)){
    node_preorder(t->root, f);
}


// -------------- PRINT -----------

static void node_print(node *n){
    printf("( ");
    if (n!=NULL){
        if (n->left!=NULL){
            node_print(n->left);
            printf(" ");
        }
        printf("%s:%d ", n->key, n->value);
        if (n->right!=NULL){
            node_print(n->right);
            printf(" ");
        }
    }
    printf(")");
}

void avltree_print(avltree *t){
    node_print(t->root);
    printf("\n");
}