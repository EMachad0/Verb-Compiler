#ifndef JASMIN_H
#define JASMIN_H

#include "../output/verb.tab.h"

typedef enum {INT_T, FLOAT_T, STR_T, ERROR_T} type_enum;

void jasmin_init();
void jasmin_delete();
void loc_uctx_init(YYLTYPE*, user_context*);
void print_code(void);
void print_error(char*);
void generate_footer();
void generate_header();
void write_code(char *s);
bool check_id(char* id);
void define_var(char* id, int type);
void assign_var(char* id);
int load_var(char* id);
void stdout_code(int );

#endif