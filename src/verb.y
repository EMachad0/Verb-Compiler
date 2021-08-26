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
}

%code provides {
    #define YY_DECL \
        int yylex(YYSTYPE* yylval, YYLTYPE* yylloc, user_context* uctx)
    YY_DECL;
    void yyerror(const YYLTYPE* yylloc, const user_context* uctx, const char* message);
}

%code {
    static void location_print(FILE* out, const YYLTYPE* loc);
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
	struct {
		struct vector *go_in, *go_out, *go_next;
	} flow_val;
}

%printer { fprintf (yyo, "%s", $$); } <sval>;
%printer { fprintf (yyo, "%d", $$); } <ival>;
%printer { fprintf (yyo, "%g", $$); } <fval>;

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
// %nterm <aast> block statement optional_block type value expr declaration assignment call
// %nterm <aast> expr_list declaration_list assignment_list flux if elseif else switch
// %nterm <aast> switch_body while do for function
%nterm <ival> expr type value call

%start program

%%

program:                                { loc_uctx_init(&@$, uctx); generate_header(source_file); } 
        block
                                        { generate_footer(); }
    ;

block:  /* nothing */                       { }
    |   statement block                     { }
    |   flux block                          { }
    // |   function block                      { }
    ;

statement:  declaration ';'                 { }
    |   assignment ';'                      { }
    |   expr ';'                            { }
    |   error ';'                           { }
    |   print ';'                           { }
    ;

optional_block: statement                   { }
    |   '{' block '}'                       { }
    |   '{' error '}'                       { }
    ;

type:   'I'                                 { $$ = INT_T; }
    |   'D'                                 { $$ = FLOAT_T; }
    |   'S'                                 { $$ = STR_T; }
    ;

value:  INTEGER                             { $$ = INT_T; write_code(concat("ldc ", i_to_str($1))); }
    |   FLOAT                               { $$ = FLOAT_T; write_code(concat("ldc ", f_to_str($1))); }
    |   STRING                              { $$ = STR_T; write_code(concat("ldc ", $1)); }
    ;    

expr:   value                               { $$ = $1; }
    |   call                                { $$ = $1; }
    // |   expr '<' expr                       { }
    // |   expr '>' expr                       { }
    // |   expr BOOLOP expr                    { }
    |   expr '|' expr                       { $$ = int_arith($1, $3, "or"); }
    |   expr '^' expr                       { $$ = int_arith($1, $3, "xor"); }
    |   expr '&' expr                       { $$ = int_arith($1, $3, "and"); }
    // |   expr CMPOP expr                     { }
    |   expr BITSHIFTOP expr                { $$ = arith($1, $3, ($2[0] == '<')? "shl":"shr"); }
    |   expr '+' expr                       { $$ = arith($1, $3, "add"); }
    |   expr '-' expr                       { $$ = arith($1, $3, "sub"); }
    |   expr '*' expr                       { $$ = arith($1, $3, "mul"); }
    |   expr '/' expr                       { $$ = arith($1, $3, "div"); }
    |   expr '%' expr                       { $$ = arith($1, $3, "rem"); }
    |   '-' expr %prec UNARYOP              { $$ = arith($2, $2, "neg"); }
    // |   '!' expr                            { }
    // |   '~' expr                            { }
    // |   expr EXPOP expr                     { }
    |   '(' expr ')'                        { $$ = $2; }
    // |   '(' error ')'                       { }
    ;

declaration:    type ID                     { define_var($2, $1); }
    |   type ID '=' expr                    { define_var($2, $1); assign_var($2, $4); }
    ;

assignment: ID '=' expr                     { assign_var($1, $3); }
    |   ID ATTOP expr                       { }
    ;

call:   ID                                  { $$ = load_var($1); }
    // |   ID UNARYOP                          { }
    // |   UNARYOP ID                          { }
    // |   ID '(' ')'                          { }
    // |   ID '(' expr_list ')'                { }
    // |   ID '(' error ')'                    { }
    ;

// expr_list:  expr                            { }
//     |   expr ',' expr_list                  { }
//     ;

declaration_list:   declaration             { }
    |   declaration ',' declaration_list    { }
    ;

assignment_list:    assignment              { }
    |   assignment ',' assignment_list      { }
    ;

flux:   if                                  { }
    |   switch                              { }
    |   while                               { }
    |   do                                  { }
    |   for                                 { }
    ;

if:     '?' '(' expr ')' optional_block elseif else     { }
    |   '?' '(' error ')' optional_block elseif else    { }
    ;

elseif: /* nothing */                                   { }
    |   '$' '(' expr ')' optional_block elseif          { }
    |   '$' '(' error ')' optional_block elseif         { }
    ;

else:   /* nothing */                                   { }
    |   ':' optional_block                              { }
    ;

switch: '#' '{' switch_body '}'                         { }
    |   '#' '{' error '}'                               { }
    ;

switch_body:    /* nothing */                           { }
    |   value ':' statement switch_body                 { }
    ;

while:  'W' '(' expr ')' optional_block else            { }
    |   'W' '(' error ')' optional_block else           { }
    ;

do:     'O' '{' block '}' while                         { }
    ;

for:    'F' '(' expr ')' optional_block else                                            { }
    |   'F' '(' INTEGER ';' expr ';' INTEGER ')' optional_block else                    { }
    |   'F' '(' declaration_list ';' expr ';' assignment_list ')' optional_block else   { }
    |   'F' '(' error ')' optional_block else                                           { }
    ;

// function:   type ID '(' declaration_list ')' optional_block                             { }
//     |   type ID '(' error ')' optional_block                                            { }
//     ;

print_list: expr                           { stdout_code($1); }
    |   expr { stdout_code($1); } ',' print_list                

print:  'P' '(' print_list ')'             { std_out_ln();    }
    ;

%%

static void location_print(FILE *out, const YYLTYPE* loc) {
    fprintf (out, "%d.%d", loc->first_line, loc->first_column - 1);
    if (loc->first_line < loc->last_line) fprintf (out, "-%d.%d", loc->last_line, loc->last_column);
    else if (loc->first_column < loc->last_column) fprintf (out, "-%d", loc->last_column);
}

static void error_line_print(FILE *out, const YYLTYPE* loc, const user_context* uctx) {
    fprintf(stderr, "%5d | %s\n", loc->first_line, uctx->line);
    fprintf(stderr, "%5s | %*s", "", loc->first_column - 1, "^");
    for (int i = loc->last_column - loc->first_column - 1; 0 <= i; --i) putc(i != 0? '~':'^', stderr);
    putc('\n', stderr);
}

void yyerror (const YYLTYPE* loc, const user_context* uctx, const char *s) {
    location_print(stderr, loc);
    fprintf (stderr, ": %s\n", s);
    error_line_print(stderr, loc, uctx);
}

static int yyreport_syntax_error(const yypcontext_t* ctx, user_context* uctx) {
    if (uctx->silent) return 0;
    int res = 0;
    const YYLTYPE* loc = yypcontext_location(ctx);
    location_print(stderr, loc);
    fprintf(stderr, ": syntax error");
    {   // Report the tokens expected at this point.
        enum { TOKENMAX = 5 };
        yysymbol_kind_t expected[TOKENMAX];
        int n = yypcontext_expected_tokens(ctx, expected, TOKENMAX);
        if (n < 0) res = n; // Forward errors to yyparse.
        else {
            for (int i = 0; i < n; ++i)
                fprintf (stderr, "%s %s", i == 0 ? ": expected":" or", yysymbol_name(expected[i]));
        }
    }
    {   // Report the unexpected token.
        yysymbol_kind_t lookahead = yypcontext_token(ctx);
        if (lookahead != YYSYMBOL_YYEMPTY)
            fprintf(stderr, " before %s", yysymbol_name(lookahead));
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

	return 0;
}