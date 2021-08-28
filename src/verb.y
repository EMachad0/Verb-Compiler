%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stdbool.h>
#include "../src/jasmin.h"
#include "../vector/vector.h"
#include "../utils/str_utils.h"

extern FILE* yyin;

bool found_error = false;

const char* source_file = "";
%}

%code requires {
    typedef struct {
        int silent;
        char *line;
    } user_context;
    typedef struct flow_t {
		struct vector *go_in, *go_out, *go_next;
	} flow_t;
}

%code provides {
    #define YY_DECL \
        int yylex(YYSTYPE* yylval, YYLTYPE* yylloc, user_context* uctx)
    YY_DECL;
    void yyerror(const YYLTYPE* yylloc, const user_context* uctx, const char* message);
}

%code {
    static void location_print(FILE* out, const YYLTYPE* loc);
    flow_t* flow_create();
    void flow_delete(flow_t* flow);
}

%verbose
%locations
%define api.pure full
%define parse.error custom
%define parse.lac full
%define parse.trace
%param { user_context* uctx }

%union {
    char *sval;
    int ival;
    double fval;
	struct flow_t* flow_val;
    struct vector* vec_val;
    struct symbol* symb_val;
}

%printer { fprintf (yyo, "%s", $$); } <sval>;
%printer { fprintf (yyo, "%d", $$); } <ival>;
%printer { fprintf (yyo, "%g", $$); } <fval>;
%printer { fprintf (yyo, "vec"); } <vec_val>;
%printer { fprintf (yyo, "symbol {%s, %d, %d}", $$->id, $$->lid, $$->type); } <symb_val>;

%token ID
%token INTEGER FLOAT STRING

/* Operator precedence */
%right '=' ATTOP
%left BOOLOP
%left '|' '^' '&'
%left '<' '>' CMPOP
%left BITSHIFTOP
%left '+' '-'
%left '*' '/' '%'
%right '!' '~' UNARYOP
%right EXPOP

%type <sval> ID STRING
%type <ival> INTEGER
%type <fval> FLOAT
%type <sval> ATTOP BOOLOP CMPOP BITSHIFTOP UNARYOP EXPOP
%nterm <ival> expr type value call label goto ifeq
%nterm <symb_val> decla_or_assign simple_declaration
%nterm <vec_val> decla_or_assign_list declaration_list
%nterm <flow_val> elseif

%start program

%%

program:    { loc_uctx_init(&@$, uctx); generate_header(source_file); generate_built_in_functions(); } 
            function_list { generate_main_header(); } block { generate_main_footer(); }
    |   error program
    ;

block:  /* nothing */
    |   statement block
    |   flux block
    ;

statement:  declaration ';'
    |   assignment ';'
    |   print ';'
    |   '=' expr ';'                        { write_return($2); }
    ;

optional_block: statement
    |   '{' block '}'
    ;

type:   'I'                                 { $$ = INT_T; }
    |   'D'                                 { $$ = FLOAT_T; }
    |   'S'                                 { $$ = STR_T; }
    |   'V'                                 { $$ = INT_T; }
    ;

value:  INTEGER                             { $$ = INT_T; write_code(concat("ldc ", i_to_str($1))); }
    |   FLOAT                               { $$ = FLOAT_T; write_code(concat("ldc ", f_to_str($1))); }
    |   STRING                              { $$ = STR_T; write_code(concat("ldc ", $1)); }
    ;    

expr:   value                               { $$ = $1; }
    |   call                                { $$ = $1; }
    |   expr '<' expr                       { $$ = cmp_arith($1, $3, "<"); }
    |   expr '>' expr                       { $$ = cmp_arith($1, $3, ">"); }
    |   expr CMPOP expr                     { $$ = cmp_arith($1, $3, $2); }
    |   expr '|' expr                       { $$ = int_arith($1, $3, "or"); }
    |   expr '^' expr                       { $$ = int_arith($1, $3, "xor"); }
    |   expr '&' expr                       { $$ = int_arith($1, $3, "and"); }
    |   expr BOOLOP expr                    { $$ = int_arith($1, $3, (strcmp($2, "||") == 0)? "or":"and"); }
    |   expr BITSHIFTOP expr                { $$ = arith($1, $3, ($2[0] == '<')? "shl":"shr"); }
    |   expr '+' expr                       { $$ = arith($1, $3, "add"); }
    |   expr '-' expr                       { $$ = arith($1, $3, "sub"); }
    |   expr '*' expr                       { $$ = arith($1, $3, "mul"); }
    |   expr '/' expr                       { $$ = arith($1, $3, "div"); }
    |   expr '%' expr                       { $$ = arith($1, $3, "rem"); }
    |   '-' expr %prec UNARYOP              { $$ = arith($2, $2, "neg"); }
    |   '!' expr                            { $$ = cmp_arith($2, INT_T, "!"); }
    // |   '~' expr                            { }
    // |   expr EXPOP expr                     { }
    |   '(' type expr ')'                   { $$ = $2; cast($3, $2); }
    |   '(' expr ')'                        { $$ = $2; }
    ;

declaration:    type decla_or_assign_list   { define_vars($1, $2); }
    ;

decla_or_assign_list: decla_or_assign               { $$ = vector_create(); vector_pushback($$, (void*) $1); }
    |   decla_or_assign ',' decla_or_assign_list    { $$ = $3; vector_pushback($$, (void*) $1); }
    ;

decla_or_assign: ID                         { $$ = make_symbol($1, -1, -1); }
    |   ID '=' expr                         { $$ = make_symbol($1, -1, $3); }
    ;

assignment: ID '=' expr                     { assign_var($1, $3, "="); }
    |   ID ATTOP expr                       { assign_var($1, $3, $2); }
    |   ID UNARYOP                          { write_code(concat_many(3, "iinc ", i_to_str(get_id($1)->lid), " 1")); }
    |   UNARYOP ID                          { write_code(concat_many(3, "iinc ", i_to_str(get_id($2)->lid), " 1")); }
    ;

call:   ID                                  { $$ = load_var($1); }
    |   ID UNARYOP                          { $$ = load_var_inc($1); }
    |   UNARYOP ID                          { $$ = load_inc_var($2); }
    |   'R' '(' type ')'                    { $$ = input_var($3); }
    |   ID '(' ')'                          { $$ = function_call($1); }
    |   ID '(' expr_list ')'                { $$ = function_call($1); }
    ;

expr_list:  expr
    |   expr ',' expr_list
    ;

assignment_list:    assignment
    |   assignment ',' assignment_list
    ;

flux:   if
    |   while
    |   for
    ;

if:     '?' '(' expr ')' ifeq optional_block goto label elseif else label 
        { backpatch($5, $8); backpatch($7, $11); backpatch_many($9->go_out, $11); }
    ;

elseif: /* nothing */                                   { $$ = flow_create(); }
    |   '$' '(' expr ')' ifeq optional_block goto label elseif
        { $$ = $9; backpatch($5, $8); vector_pushback_ll($9->go_out, $7); }
    ;

else:   /* nothing */
    |   ':' optional_block
    ;

while:  'W' label '(' expr ')' ifeq optional_block goto label    { backpatch($6, $9); backpatch($8, $2); }
    ;

for:    'F' '(' INTEGER ')' ifeq optional_block goto label
    |   'F' '(' declaration ';' label expr ifeq goto ';' label assignment_list goto ')' label optional_block goto label
        { backpatch($7, $17); backpatch($8, $14); backpatch($16, $10); backpatch($12, $5); }
    ;

function:   '@' type ID '(' ')'
            { write_function_header(function_create($2, $3, vector_create())); }
            optional_block { write_function_footer($2); }
    |       '@' type ID '(' declaration_list ')'
            { write_function_header(function_create($2, $3, $5)); }
            optional_block { write_function_footer($2); }
    ;

function_list: /* nothing */ 
    | function function_list
    ;

simple_declaration: type ID                 { $$ = make_symbol($2, -1, $1); }
    ;

declaration_list:   simple_declaration          { $$ = vector_create(); vector_pushback($$, (void*) $1); }
    |   simple_declaration ',' declaration_list { $$ = $3; vector_pushback($$, (void*) $1); }
    ;

print_list: expr                            { stdout_code($1); }
    |   expr                                { stdout_code($1); } ',' print_list                
    ;

print:  'P' '(' print_list ')'              { std_out_ln(); }
    ;

label:  /* nothing */                       { $$ = write_label(); }
    ;

goto:  /* nothing */                        { $$ = write_code("goto L_"); }
    ;

ifeq:  /* nothing */                        { $$ = write_code("ifeq L_"); }
    ;

%%

static void location_print(FILE *out, const YYLTYPE* loc) {
    fprintf (out, BLUE "%d.%d" RESET, loc->first_line, loc->first_column - 1);
    if (loc->first_line < loc->last_line) fprintf (out, BLUE "-%d.%d" RESET, loc->last_line, loc->last_column);
    else if (loc->first_column < loc->last_column) fprintf (out, BLUE "-%d" RESET, loc->last_column);
}

static void error_line_print(FILE *out, const YYLTYPE* loc, const user_context* uctx) {
    fprintf(stderr, "%5d | %s\n", loc->first_line, uctx->line);
    fprintf(stderr, "%5s | %*s", "", loc->first_column - 1, "^");
    for (int i = loc->last_column - loc->first_column - 1; 0 <= i; --i) putc(i != 0? '~':'^', stderr);
    putc('\n', stderr);
}

void yyerror (const YYLTYPE* loc, const user_context* uctx, const char *s) {
    found_error = true;
    location_print(stderr, loc);
    fprintf (stderr, ": %s\n", s);
    error_line_print(stderr, loc, uctx);
}

static int yyreport_syntax_error(const yypcontext_t* ctx, user_context* uctx) {
    found_error = true;
    if (uctx->silent) return 0;
    int res = 0;
    const YYLTYPE* loc = yypcontext_location(ctx);
    location_print(stderr, loc);
    fprintf(stderr, ":" RED " syntax error" RESET ": ");
    {   // Report the tokens expected at this point.
        enum { TOKENMAX = 5 };
        yysymbol_kind_t expected[TOKENMAX];
        int n = yypcontext_expected_tokens(ctx, expected, TOKENMAX);
        if (n < 0) res = n; // Forward errors to yyparse.
        else {
            for (int i = 0; i < n; ++i)
                fprintf (stderr, "%s %s", i == 0 ? " expected":" or", to_yellow(yysymbol_name(expected[i])));
        }
    }
    {   // Report the unexpected token.
        yysymbol_kind_t lookahead = yypcontext_token(ctx);
        if (lookahead != YYSYMBOL_YYEMPTY)
            fprintf(stderr, " before %s", to_yellow(yysymbol_name(lookahead)));
    }
    fprintf(stderr, "\n");
    error_line_print(stderr, loc, uctx);
    return res;
}

user_context* init_uctx() {
    user_context* uctx = malloc(sizeof(user_context));
    uctx->silent = 0;
    uctx->line = malloc(500 * sizeof(char));
    return uctx;
}

void free_uctx(user_context* uctx) {
    free(uctx->line);
    free(uctx);
}

flow_t* flow_create() {
    flow_t* flow = malloc(sizeof(flow_t));
    flow->go_in = vector_create();
    flow->go_out = vector_create();
    flow->go_next = vector_create();
    return flow;
}

void flow_delete(flow_t* flow) {
    vector_delete(flow->go_in);
    vector_delete(flow->go_out);
    vector_delete(flow->go_next);
    free(flow);
}

int main(int argc, const char **argv) {
    yyin = stdin;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-p") == 0) yydebug = 1;
        else {
            printf("Compiling %s\n", argv[i]);
            source_file = (source_file[0] == '.')? argv[i]+1 : argv[i];
            yyin = fopen(argv[i], "r");
        } 
    }

    user_context* uctx = init_uctx();
    jasmin_init();

	do {
		yyparse(uctx);
	} while(!feof(yyin));

    if (!found_error && source_file) print_code();

    free_uctx(uctx);
    jasmin_delete();

	return found_error;
}