#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "jasmin.h"
#include "../utils/str_utils.h"

int id_cont, label_cont;
hashmap* id_map;
vector* code_list;
user_context* uctx;
YYLTYPE* loc;

void jasmin_init() {
	id_cont = label_cont = 1;
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

int write_code(char *s) {
	vector_pushback_char(code_list, s);
	return vector_size(code_list) - 1;
}

void write_line(int n) {
	write_code(concat(".line ", i_to_str(n)));
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

bool check_id(const char* id) {
	return hashmap_has(id_map, id);
}

void write_const(int type) {
	if (type == INT_T) {
		write_code("iconst_0");
	} else if (type == FLOAT_T) {
		write_code("fconst_0");
	} else if (type == STR_T) {
		write_code("aconst_null");
	}
}

void write_store(int type, int lid) {
	if (type == INT_T) {
		write_code(concat("istore ", i_to_str(lid)));
	} else if (type == FLOAT_T) {
		write_code(concat("fstore ", i_to_str(lid)));
	} else if (type == STR_T) {
		write_code(concat("astore ", i_to_str(lid)));
	}
}

void write_load(int type, int lid) {
	if (type == INT_T) {
		write_code(concat("iload ", i_to_str(lid)));
	} else if (type == FLOAT_T) {
		write_code(concat("fload ", i_to_str(lid)));
	} else if (type == STR_T) {
		write_code(concat("aload ", i_to_str(lid)));
	}
}

int write_label() {
	write_code(concat_many(3, "L_", i_to_str(label_cont), ":"));
	return label_cont++;
}

void assign_var(char* id, int type, char* op) {
	if (!check_id(id)) {
		print_error(concat_many(3, RED_ERROR ": variable ", to_yellow(id), " not declared"));
		return;
	}
	symbol* smb = get_symbol(id_map, id);
	if (strcmp(op, "=") != 0) {
		write_load(smb->type, smb->lid);
		if (strcmp(op, "+=") == 0) arith(type, smb->type, "add");
		else if (strcmp(op, "*=") == 0) arith(type, smb->type, "mul");
		else if (strcmp(op, "&=") == 0) int_arith(type, smb->type, "and");
		else if (strcmp(op, "^=") == 0) int_arith(type, smb->type, "xor");
		else if (strcmp(op, "|=") == 0) int_arith(type, smb->type, "or");
		else {
			write_code("swap");
			if (strcmp(op, "-=") == 0) arith(smb->type, type, "sub");
			else if (strcmp(op, "/=") == 0) arith(smb->type, type, "div");
			else if (strcmp(op, "%=") == 0) arith(smb->type, type, "rem");
			else if (strcmp(op, "<<=") == 0) int_arith(smb->type, type, "shl");
			else if (strcmp(op, ">>=") == 0) int_arith(smb->type, type, "shr");
			else if (strcmp(op, "**") == 0) print_error("Exponentiation not yet supported :(");
		}
	} else if (smb->type != type) cast(type, smb->type);
	write_store(smb->type, smb->lid);
}

int load_var(char* id) {
	if (!check_id(id)) {
		print_error(concat_many(3, RED_ERROR ": variable ", to_yellow(id), " not declared"));
		write_const(INT_T);
		return INT_T;
	}
	symbol* smb = get_symbol(id_map, id);
	write_load(smb->type, smb->lid);
	return smb->type;
}

void define_vars(int type, vector *vec) {
	for (int i = 0; i < vector_size(vec); i++) {
		symbol* smb = vector_get(vec, i);
		if (check_id(smb->id)) {
			print_error(concat_many(3, RED_ERROR ": variable ", to_yellow(smb->id), " already declared"));
			continue;
		}
		if (smb->type != -1) {
			if (smb->type != type) cast(smb->type, type);
		} else write_const(type);
		write_store(type, id_cont);
		set_symbol(id_map, smb->id, id_cont++, type);
	}
}

void stdout_code(int type) {
	if (type == INT_T) {
		write_code("invokestatic output/Verb/output_int(I)V");
	} else if (type == FLOAT_T) {
		write_code("invokestatic output/Verb/output_float(F)V");
	} else if (type == STR_T) {
		write_code("invokestatic output/Verb/output_str(Ljava/lang/String;)V");
	}
}

void std_out_ln() {
	write_code("invokestatic output/Verb/outputln()V");
}

int arith(int t1, int t2, char* opcode) {
	if (t1 == STR_T || t2 == STR_T) {
		print_error(RED_ERROR ": Invalid operator for type string literal");
		return ERROR_T;
	}
	if (t1 == t2) {
		write_code(concat((t1 == INT_T)? "i":"f", opcode));
		return t1;
	}
	if (t1 == FLOAT_T) cast(t2, t1);
	else write_code("swap"), cast(t1, t2);
	write_code(concat("f", opcode));
	return FLOAT_T;
}

int int_arith(int t1, int t2, char* opcode) {
	if (t1 != INT_T || t2 != INT_T) {
		print_error(concat_many(6, RED_ERROR ": Invalid operator for types ", to_yellow(get_type_string(t1)), " and ", to_yellow(get_type_string(t2)), " expect ", to_yellow("INT_T")));
		return ERROR_T;
	}
	write_code(concat("i", opcode));
	return INT_T;
}

int cmp_arith(int t1, int t2, char* op) {
	if (t1 != t2) {
		print_error(concat_many(4, RED_ERROR ": Invalid comparison of types ", to_yellow(get_type_string(t1)), " and ", to_yellow(get_type_string(t2))));
		return ERROR_T;
	} else if (t1 == INT_T) {
		if (strcmp(op, "==") == 0) {
			write_code(concat("if_icmpeq L_", i_to_str(label_cont)));
		} else if (strcmp(op, "!=") == 0) {
			write_code(concat("if_icmpne L_", i_to_str(label_cont)));
		} else if (strcmp(op, "<") == 0) {
			write_code(concat("if_icmplt L_", i_to_str(label_cont)));
		} else if (strcmp(op, "<=") == 0) {
			write_code(concat("if_icmple L_", i_to_str(label_cont)));
		} else if (strcmp(op, ">") == 0) {
			write_code(concat("if_icmpgt L_", i_to_str(label_cont)));
		} else if (strcmp(op, ">=") == 0) {
			write_code(concat("if_icmpge L_", i_to_str(label_cont)));
		} else if (strcmp(op, "!") == 0) {
			write_code(concat("ifeq L_", i_to_str(label_cont)));
		} else {
			print_error(concat_many(6, RED_ERROR ": Invalid operator (", to_yellow(op), ") for types ", to_yellow(get_type_string(t1)), " and ", to_yellow(get_type_string(t1))));
			return ERROR_T;
		}
	} else if (t1 == FLOAT_T) {
		write_code("fcmpg");
		if (strcmp(op, "==") == 0) {
			write_code(concat("ifeq L_", i_to_str(label_cont)));
		} else if (strcmp(op, "!=") == 0) {
			write_code(concat("ifne L_", i_to_str(label_cont)));
		} else if (strcmp(op, "<") == 0) {
			write_code(concat("iflt L_", i_to_str(label_cont)));
		} else if (strcmp(op, "<=") == 0) {
			write_code(concat("ifle L_", i_to_str(label_cont)));
		} else if (strcmp(op, ">") == 0) {
			write_code(concat("ifgt L_", i_to_str(label_cont)));
		} else if (strcmp(op, ">=") == 0) {
			write_code(concat("ifge L_", i_to_str(label_cont)));
		} else {
			print_error(concat_many(6, RED_ERROR ": Invalid operator (", to_yellow(op), ") for types ", to_yellow(get_type_string(t1)), " and ", to_yellow(get_type_string(t1))));
			return ERROR_T;
		}
	} else if (t1 == STR_T) {
		if (strcmp(op, "==") == 0) {
			write_code(concat("if_acmpeq L_", i_to_str(label_cont)));
		} else if (strcmp(op, "!=") == 0) {
			write_code(concat("if_acmpne L_", i_to_str(label_cont)));
		} else {
			print_error(concat_many(6, RED_ERROR ": Invalid operator (", to_yellow(op), ") for types ", to_yellow(get_type_string(t1)), " and ", to_yellow(get_type_string(t1))));
			return ERROR_T;
		}
	}
	write_code("iconst_0");
	write_code(concat("goto L_", i_to_str(label_cont + 1)));
	write_label();
	write_code("iconst_1");
	write_label();
	return INT_T;
}

void cast(int t1, int t2) {
	if (t1 == t2) return;
	if (t1 == STR_T || t2 == STR_T) {
		print_error(RED_ERROR ": Impossible to cast string");
		return;
	}
	write_code(concat_many(3, t1 == INT_T? "i":"f", "2", t2 == INT_T? "i":"f"));
}

char* get_type_string(int type) {
	switch (type) {
		case INT_T: return "INT_T";
		case STR_T: return "STR_T";
		case FLOAT_T: return "FLOAT_T";
	}
}

symbol* get_id(char* id) {
	return get_symbol(id_map, id);
}

int load_inc_var(char* id) {
	symbol* smb = get_id(id);
	if (smb->type != INT_T) {
		print_error(concat_many(3, RED_ERROR ": Invalid operator for type ", get_type_string(smb->type), " expect INT_T"));
		return ERROR_T;
	}
	write_code(concat_many(3, "iinc ", i_to_str(smb->lid), " 1"));
	load_var(id);
	return INT_T;
}

int load_var_inc(char* id) {
	symbol* smb = get_id(id);
	if (smb->type != INT_T) {
		print_error(concat_many(4, RED_ERROR ": Invalid operator for type ", get_type_string(smb->type), " expect INT_T"));
		return ERROR_T;
	}
	load_var(id);
	write_code(concat_many(3, "iinc ", i_to_str(smb->lid), " 1"));
	return INT_T;
}

void backpatch(int pos, int l_idx) {
	char* idx_s = i_to_str(l_idx);
	char* ori = vector_get_char(code_list, pos);
	vector_set_char(code_list, pos, concat(ori, idx_s));
	free(idx_s);
}

void backpatch_many(vector *vec, int l_idx) {
	if (vector_empty(vec)) return;
	char* idx_s = i_to_str(l_idx);
	int idx_sz = strlen(idx_s);
	for(int i = 0; i < vector_size(vec); i++) {
		int pos = vector_get_ll(vec, i);
		char* ori = vector_get_char(code_list, pos);
		vector_set_char(code_list, pos, concat(ori, idx_s));
	}
	free(idx_s);
}

void input_var(int type) {
	if (type == INT_T) {
		write_code("invokestatic output/Verb/input_int()I");
	} else if (type == FLOAT_T) {
		write_code("invokestatic output/Verb/input_float()F");
	} else if (type == STR_T) {
		print_error("String nput not implemented");
	}
}

void generate_footer() {
	write_code("; code end");
	write_code("return");
	write_code(".end method");
}

void generate_header(char* source_file) {
	write_code(concat(".source ", source_file));
	write_code(".class public output/Verb\n.super java/lang/Object\n"); //code for defining class
	write_code(".method public <init>()V");
	write_code("	aload_0");
	write_code("	invokenonvirtual java/lang/Object/<init>()V");
	write_code("	return");
	write_code(".end method\n");
	write_code(".method public static input_int()I");
	write_code("	.limit locals 10");
	write_code("	.limit stack 10");
	write_code("	ldc 0");
	write_code("	istore 1");
	write_code("Label1:");
	write_code("	getstatic java/lang/System/in Ljava/io/InputStream;");
	write_code("	invokevirtual java/io/InputStream/read()I");
	write_code("	istore 2");
	write_code("	iload 2");
	write_code("	ldc 10");
	write_code("	isub");
	write_code("	ifeq Label2");
	write_code("	iload 2");
	write_code("	ldc 32");
	write_code("	isub");
	write_code("	ifeq Label2");
	write_code("	iload 2");
	write_code("	ldc 48");
	write_code("	isub");
	write_code("	ldc 10");
	write_code("	iload 1");
	write_code("	imul");
	write_code("	iadd");
	write_code("	istore 1");
	write_code("	goto Label1");
	write_code("Label2:");
	write_code("	iload 1");
	write_code("	ireturn");
	write_code(".end method\n");
	write_code(".method public static input_float()F");
	write_code("	.limit locals 10");
	write_code("	.limit stack 10");
	write_code("	ldc 0.0");
	write_code("	fstore 1");
	write_code("	ldc 0");
	write_code("	istore 3");
	write_code("Label1:");
	write_code("	getstatic java/lang/System/in Ljava/io/InputStream;");
	write_code("	invokevirtual java/io/InputStream/read()I");
	write_code("	istore 2");
	write_code("	iload 2");
	write_code("	ldc 10");
	write_code("	isub");
	write_code("	ifeq Label3");
	write_code("	iload 2");
	write_code("	ldc 32");
	write_code("	isub");
	write_code("	ifeq Label3");
	write_code("	iload 2");
	write_code("	ldc 46");
	write_code("	isub");
	write_code("	ifeq Label2");
	write_code("	iload 2");
	write_code("	ldc 48");
	write_code("	isub");
	write_code("	i2f");
	write_code("	ldc 10.0");
	write_code("	fload 1");
	write_code("	fmul");
	write_code("	fadd");
	write_code("	fstore 1");
	write_code("	goto Label1");
	write_code("Label2:");
	write_code("	getstatic java/lang/System/in Ljava/io/InputStream;");
	write_code("	invokevirtual java/io/InputStream/read()I");
	write_code("	istore 2");
	write_code("	iload 2");
	write_code("	ldc 10");
	write_code("	isub");
	write_code("	ifeq Label3");
	write_code("	iload 2");
	write_code("	ldc 32");
	write_code("	isub");
	write_code("	ifeq Label3");
	write_code("	iload 2");
	write_code("	ldc 48");
	write_code("	isub");
	write_code("	i2f");
	write_code("	ldc 10.0");
	write_code("	fload 1");
	write_code("	fmul");
	write_code("	fadd");
	write_code("	fstore 1");
	write_code("	iinc 3 1");
	write_code("	goto Label2");
	write_code("Label3:");
	write_code("	iload 3");
	write_code("	ifeq Label4");
	write_code("	fload 1");
	write_code("	ldc 10.0");
	write_code("	fdiv");
	write_code("	fstore 1");
	write_code("	iinc 3 -1");
	write_code("	goto Label3");
	write_code("Label4:");
	write_code("	fload 1");
	write_code("	freturn");
	write_code(".end method\n");
	write_code(".method public static output_int(I)V");
	write_code("	.limit locals 5");
	write_code("	.limit stack 5");
	write_code("	getstatic java/lang/System/out Ljava/io/PrintStream;");
	write_code("	iload 0  ; the argument to function");
	write_code("	invokevirtual java/io/PrintStream/print(I)V");
	write_code("	return");
	write_code(".end method\n");
	write_code(".method public static output_float(F)V");
	write_code("	.limit locals 5");
	write_code("	.limit stack 5");
	write_code("	getstatic java/lang/System/out Ljava/io/PrintStream;");
	write_code("	fload 0  ; the argument to function");
	write_code("	invokevirtual java/io/PrintStream/print(F)V");
	write_code("	return");
	write_code(".end method\n");
	write_code(".method public static output_str(Ljava/lang/String;)V");
	write_code("	.limit locals 5");
	write_code("	.limit stack 5");
	write_code("	getstatic java/lang/System/out Ljava/io/PrintStream;");
	write_code("	aload 0");
	write_code("	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V");
	write_code("	return");
	write_code(".end method\n");
	write_code(".method public static outputln()V");
	write_code("	.limit locals 5");
	write_code("	.limit stack 5");
	write_code("	getstatic java/lang/System/out Ljava/io/PrintStream;");
	write_code("	invokevirtual java/io/PrintStream/println()V");
	write_code("	return");
	write_code(".end method\n");
	write_code(".method public static main([Ljava/lang/String;)V");
	write_code(".limit locals 100\n.limit stack 100");
	/*generate line*/
	write_code("; code start");
	write_line(1);
}