#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "jasmin.h"
#include "../vector/vector.h"
#include "../hashmap/hashmap.h"
#include "../utils/str_utils.h"

int id_cont;
hashmap* id_map;
vector* code_list;
user_context* uctx;
YYLTYPE* loc;

void jasmin_init() {
	id_cont = 1;
    id_map = hashmap_create(100005); 
    code_list = vector_create(); 
}

void jasmin_delete() {
    hashmap_delete(id_map);
    vector_delete(code_list);
}

void loc_uctx_init(YYLTYPE* _loc, user_context* _uctx) {
	uctx = _uctx;
	loc = _loc;
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

void print_error(char* msg) {
	yyerror(loc, uctx, msg);
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
	} else if (type == STR_T) {
		write_code("aconst_null");
		write_code(concat("astore ", i_to_str(id_cont)));
	}
	set_symbol(id_map, id, id_cont++, type);
}

void assign_var(char* id) {
	symbol* smb = get_symbol(id_map, id);
	if (smb->type == INT_T) {
		write_code(concat("istore ", i_to_str(smb->value)));
	} else if (smb->type == FLOAT_T) {
		write_code(concat("fstore ", i_to_str(smb->value)));
	} else if (smb->type == STR_T) {
		write_code(concat("astore ", i_to_str(smb->value)));
	}
}

int load_var(char* id) {
	symbol* smb = get_symbol(id_map, id);
	if (smb->type == INT_T) {
		write_code(concat("iload ", i_to_str(smb->value)));
	} else if (smb->type == FLOAT_T) {
		write_code(concat("fload ", i_to_str(smb->value)));
	} else if (smb->type == STR_T) {
		write_code(concat("aload ", i_to_str(smb->value)));
	}
	return smb->type;
}

void stdout_code(int type) {
	if (type == INT_T) {
		write_code("getstatic java/lang/System/out Ljava/io/PrintStream;");
		write_code("swap");
		write_code("invokevirtual java/io/PrintStream/print(I)V");
	} else if (type == FLOAT_T) {
		write_code("getstatic java/lang/System/out Ljava/io/PrintStream;");
		write_code("swap");
		write_code("invokevirtual java/io/PrintStream/print(F)V");
	} else if (type == STR_T) {
		write_code("getstatic java/lang/System/out Ljava/io/PrintStream;");
		write_code("swap");
		write_code("invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V");	
	}
}

void std_out_ln() {
	write_code("getstatic java/lang/System/out Ljava/io/PrintStream;");
	write_code("invokevirtual java/io/PrintStream/println()V");
}

int arith(int t1, int t2, char* opcode) {
	if (t1 == STR_T || t2 == STR_T) {
		print_error("Invalid operator for type string literal");
		return ERROR_T;
	}
	if (t1 == t2) {
		write_code(concat((t1 == INT_T)? "i":"f", opcode));
		return t1;
	}
	print_error("Type cast not implemented"); // todo type cast
}

symbol* get_id(char* id) {
	return get_symbol(id_map, id);
}
