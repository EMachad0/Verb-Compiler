#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "jasmin.h"
#include "../vector/vector.h"
#include "../hashmap/hashmap.h"
#include "../hashmap/hashmap_symbol.h"
#include "../utils/str_utils.h"
#include "../output/verb.tab.h"

int id_cont;
hashmap* id_map;
vector* code_list;

void jasmin_init() {
	id_cont = 1;
    id_map = hashmap_create(100005); 
    code_list = vector_create(); 
}

void jasmin_delete() {
    hashmap_delete(id_map);
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
	write_code(".class public output/Verb\n.super java/lang/Object\n"); //code for defining class
	write_code(".method public <init>()V");
	write_code("\taload_0");
	write_code("\tinvokenonvirtual java/lang/Object/<init>()V");
	write_code("\treturn");
	write_code(".end method\n");
	write_code(".method public static main([Ljava/lang/String;)V");
	write_code(".limit locals 100\n.limit stack 100");
	/* generate temporal vars for syso*/
	define_var("1syso_int_var", INT_T);
	define_var("1syso_float_var", FLOAT_T);
	/*generate line*/
	write_code("; code start");
	write_line(1);
}

void generate_footer() {
	write_code("; code end");
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

bool check_id(char* id) {
	return hashmap_has(id_map, id);
}

void define_var(char* id, int type) {
	if (type == INT_T) {
		write_code("iconst_0");
		write_code(concat("istore ", i_to_str(id_cont)));
	} else if (type == FLOAT_T) {
		write_code("fconst_0");
		write_code(concat("fstore ", i_to_str(id_cont)));
	}
	set_symbol(id_map, id, id_cont++, type);
}

void assign_var(char* id) {
	symbol* smb = get_symbol(id_map, id);
	if (smb->type == INT_T) {
		write_code(concat("istore ", i_to_str(smb->value)));
	} else if (smb->type == FLOAT_T) {
		write_code(concat("fstore ", i_to_str(smb->value)));
	}
}

int load_var(char* id) {
	symbol* smb = get_symbol(id_map, id);
	if (smb->type == INT_T) {
		write_code(concat("iload ", i_to_str(smb->value)));
	} else if (smb->type == FLOAT_T) {
		write_code(concat("fload ", i_to_str(smb->value)));
	}
	return smb->type;
}

void stdout_code(int type) {
	if (type == INT_T) {
		/* expression is at top of stack now */
		/* save it at the predefined temp syso var */
		write_code(concat("istore ", i_to_str(get_symbol(id_map, "1syso_int_var")->value)));
		/* call syso */	
		write_code("getstatic      java/lang/System/out Ljava/io/PrintStream;");
		/*insert param*/
		write_code(concat("iload ", i_to_str(get_symbol(id_map, "1syso_int_var")->value)));
		/*invoke syso*/
		write_code("invokevirtual java/io/PrintStream/println(I)V");
	} else if (type == FLOAT_T) {
		write_code(concat("fstore ", i_to_str(get_symbol(id_map, "1syso_float_var")->value)));
		write_code("getstatic      java/lang/System/out Ljava/io/PrintStream;");
		write_code(concat("fload ", i_to_str(get_symbol(id_map, "1syso_float_var")->value)));
		write_code("invokevirtual java/io/PrintStream/println(F)V");	
	}
}
