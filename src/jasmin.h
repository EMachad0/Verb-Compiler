#ifndef JASMIN_H
#define JASMIN_H

typedef enum {INT_T, FLOAT_T, STR_T, ERROR_T} type_enum;

void jasmin_init();
void jasmin_delete();
void print_code(void);
void generate_footer();
void generate_header();
void write_code(char *s);
bool check_id(char* id);
void define_var(char* id, int type);
#endif