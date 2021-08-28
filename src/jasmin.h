#ifndef JASMIN_H
#define JASMIN_H

#include "../output/verb.tab.h"
#include "../vector/vector.h"
#include "../hashmap/hashmap.h"
#include "../hashmap/hashmap_symbol.h"

typedef enum {INT_T, FLOAT_T, STR_T, ERROR_T, VOID_T, FUNCTION_T } type_enum;

void jasmin_init();
void jasmin_delete();
void loc_uctx_init(YYLTYPE*, user_context*);
void print_code(void);
void print_error(char*);
int write_code(char *s);
bool check_id(const char* id);
void set_id(const char* id, int type);
void write_const(int type);
void write_store(int type, int lid);
void write_load(int type, int lid);
int write_label();
void define_var(char* id, int type);
void assign_var(char* id, int type, char* op);
void define_vars(int type, vector *vec);
int load_var(char* id);
int load_inc_var(char* id);
int load_var_inc(char* id);
void stdout_code(int );
int arith(int t1, int t2, char* opcode);
int int_arith(int t1, int t2, char* opcode);
int cmp_arith(int t1, int t2, char* op);
symbol* get_id(char* id);
char* get_type_string(int type);
void std_out_ln();
void cast(int t1, int t2);
void backpatch(int pos, int l_idx);
void backpatch_many(vector *vec, int l_idx);
int input_var(int type);

typedef struct function_t {
    char* name;
    char* full_header;
    vector* params;
    int type;
    int lid;
} function_t;

function_t* function_create(int type, char *name, vector* params);
void write_function_header(function_t*);
void write_return(int type);
void write_function_footer(int type);
int function_call(char* name);

void generate_header(const char *source);
void generate_built_in_functions();
void generate_main_header();
void generate_main_footer();

#endif