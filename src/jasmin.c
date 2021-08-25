#include <stdio.h>
#include <stdlib.h>
#include "jasmin.h"
#include "../vector/vector.h"
#include "../hashmap/hashmap.h"
#include "../hashmap/hashmap_symbol.h"
#include "../utils/str_utils.h"

hashmap* id_tab;
vector* code_list;

void jasmin_init() {
    id_tab = hashmap_create(100005); 
    code_list = vector_create(); 
}

void jasmin_delete() {
    hashmap_delete(id_tab);
    vector_delete(code_list);
}

void write_code(char *s) {
	vector_pushback_char(code_list, s);
}

void write_line(int n) {
	write_code(concat(".line ", i_to_str(n))); /* TODO LINE GENERATION */
}

void generate_header(char* source_file) {
	write_code(concat(".source ", source_file));
	write_code(".class public test\n.super java/lang/Object\n"); //code for defining class
	write_code(".method public <init>()V");
	write_code("\taload_0");
	write_code("\tinvokenonvirtual java/lang/Object/<init>()V");
	write_code("\treturn");
	write_code(".end method\n");
	write_code(".method public static main([Ljava/lang/String;)V");
	write_code(".limit locals 100\n.limit stack 100");
	/* generate temporal vars for syso*/
	// defineVar("1syso_int_var",INT_T);
	// defineVar("1syso_float_var",FLOAT_T);
	/*generate line*/
	// write_line(1);
}

void generate_footer() {
	write_code("return");
	write_code(".end method");
}

void print_code(void) {
    FILE* f = fopen("output/verb.j", "w");
    for (int i = 0; i < vector_size(code_list); i++) {
        fprintf(f, "%s\n", vector_get_char(code_list, i));
    }
    fclose(f);
}
