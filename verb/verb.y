%{
# include <stdio.h>
# include <stdlib.h>
# include <stdbool.h>
# include <string.h>
# include "verb.h"

extern FILE* yyin;

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
%param { user_context* uctx}

%union {
    char *str, *op;
    int int_val;
    double flt_val;
    ast* aast;
}

%printer { fprintf (yyo, "%s", $$); } <str> <op>;
// %printer { fprintf (yyo, "%d", $$); } <int_val>;
// %printer { fprintf (yyo, "%g", $$); } <flt_val>;

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

%type <str> ID STRING INTEGER FLOAT
%type <op> ATTOP BOOLOP CMPOP BITSHIFTOP UNARYOP EXPOP
%nterm <aast> block statement optional_block type value expr declaration assignment call
%nterm <aast> expr_list declaration_list assignment_list flux if elseif else switch
%nterm <aast> switch_body while do for function

%start program

%%

program:    block                           { print_dot_tree($1); free_tree($1); }
    ;

block:  /* nothing */                       { $$ = new_ast("ϵ", NULL, NULL); }
    |   statement block                     { $$ = new_ast("statement", $1, new_ast("block", $2, NULL)); }
    |   flux block                          { $$ = new_ast("flux", $1, new_ast("block", $2, NULL)); }
    |   function block                      { $$ = new_ast("function", $1, new_ast("block", $2, NULL)); }
    ;

statement:  declaration ';'                 { $$ = new_ast("declaration", $1, new_ast(";", NULL, NULL)); }
    |   assignment ';'                      { $$ = new_ast("assignment", $1, new_ast(";", NULL, NULL)); }
    |   expr ';'                            { $$ = new_ast("expr", $1, new_ast(";", NULL, NULL)); }
    |   error ';'                           { $$ = new_ast("error", NULL, new_ast(";", NULL, NULL)); }
    ;

optional_block: statement                   { $$ = new_ast("statement", $1, NULL); }
    |   '{' block '}'                       { $$ = new_ast("{", NULL, new_ast("block", $2, new_ast("}", NULL, NULL))); }
    |   '{' error '}'                       { $$ = new_ast("{", NULL, new_ast("error", NULL, new_ast("}", NULL, NULL))); }
    ;

type:   'I'                                 { $$ = new_ast("I", NULL, NULL); }
    |   'D'                                 { $$ = new_ast("D", NULL, NULL); }
    |   'S'                                 { $$ = new_ast("S", NULL, NULL); }
    ;

value:  INTEGER                             { $$ = new_ast($1, NULL, NULL); }
    |   FLOAT                               { $$ = new_ast($1, NULL, NULL); }
    |   STRING                              { $$ = new_ast($1, NULL, NULL); }
    ;    

expr:   value                               { $$ = new_ast("value", $1, NULL); }
    |   call                                { $$ = new_ast("call", $1, NULL); }
    |   expr '<' expr                       { $$ = new_ast("expr", $1, new_ast("<", NULL, new_ast("expr", $3, NULL))); }
    |   expr '>' expr                       { $$ = new_ast("expr", $1, new_ast(">", NULL, new_ast("expr", $3, NULL))); }
    |   expr BOOLOP expr                    { $$ = new_ast("expr", $1, new_ast($2, NULL, new_ast("expr", $3, NULL))); }
    |   expr '|' expr                       { $$ = new_ast("expr", $1, new_ast("|", NULL, new_ast("expr", $3, NULL))); }
    |   expr '^' expr                       { $$ = new_ast("expr", $1, new_ast("^", NULL, new_ast("expr", $3, NULL))); }
    |   expr '&' expr                       { $$ = new_ast("expr", $1, new_ast("&", NULL, new_ast("expr", $3, NULL))); }
    |   expr CMPOP expr                     { $$ = new_ast("expr", $1, new_ast($2, NULL, new_ast("expr", $3, NULL))); }
    |   expr BITSHIFTOP expr                { $$ = new_ast("expr", $1, new_ast($2, NULL, new_ast("expr", $3, NULL))); }
    |   expr '+' expr                       { $$ = new_ast("expr", $1, new_ast("+", NULL, new_ast("expr", $3, NULL))); }
    |   expr '-' expr                       { $$ = new_ast("expr", $1, new_ast("-", NULL, new_ast("expr", $3, NULL))); }
    |   expr '*' expr                       { $$ = new_ast("expr", $1, new_ast("*", NULL, new_ast("expr", $3, NULL))); }
    |   expr '/' expr                       { $$ = new_ast("expr", $1, new_ast("/", NULL, new_ast("expr", $3, NULL))); }
    |   expr '%' expr                       { $$ = new_ast("expr", $1, new_ast("%", NULL, new_ast("expr", $3, NULL))); }
    |   '-' expr %prec UNARYOP              { $$ = new_ast("-", NULL, new_ast("expr", $2, NULL)); }
    |   '!' expr                            { $$ = new_ast("!", NULL, new_ast("expr", $2, NULL)); }
    |   '~' expr                            { $$ = new_ast("~", NULL, new_ast("expr", $2, NULL)); }
    |   expr EXPOP expr                     { $$ = new_ast("expr", $1, new_ast($2, NULL, new_ast("expr", $3, NULL))); }
    |   '(' expr ')'                        { $$ = new_ast("(", NULL, new_ast("expr", $2, new_ast(")", NULL, NULL))); }
    |   '(' error ')'                       { $$ = new_ast("(", NULL, new_ast("error", NULL, new_ast(")", NULL, NULL))); }
    ;

declaration:    type ID                     { $$ = new_ast("type", $1, new_ast($2, NULL, NULL)); }
    |   type ID '=' expr                    { $$ = new_ast("type", $1, new_ast($2, NULL, new_ast("=", NULL, new_ast("expr", $4, NULL)))); }
    ;

assignment: ID '=' expr                     { $$ = new_ast($1, NULL, new_ast("=", NULL, new_ast("expr", $3, NULL))); }
    |   ID ATTOP expr                       { $$ = new_ast($1, NULL, new_ast($2, NULL, new_ast("expr", $3, NULL))); }
    ;

call:   ID                                  { $$ = new_ast($1, NULL, NULL); }
    |   ID UNARYOP                          { $$ = new_ast($1, NULL, new_ast($2, NULL, NULL)); }
    |   UNARYOP ID                          { $$ = new_ast($1, NULL, new_ast($2, NULL, NULL)); }
    |   ID '(' ')'                          { $$ = new_ast($1, NULL, new_ast("(", NULL,  new_ast(")", NULL, NULL))); }
    |   ID '(' expr_list ')'                { $$ = new_ast($1, NULL, new_ast("(", NULL, new_ast("expr_list", $3, new_ast(")", NULL, NULL)))); }
    |   ID '(' error ')'                    { $$ = new_ast($1, NULL, new_ast("(", NULL, new_ast("error", NULL, new_ast(")", NULL, NULL)))); }
    ;

expr_list:  expr                            { $$ = new_ast("expr", $1, NULL); }
    |   expr ',' expr_list                  { $$ = new_ast("expr", $1, new_ast(",", NULL, new_ast("expr_list", $3, NULL))); }
    ;

declaration_list:   declaration             { $$ = new_ast("declaration", $1, NULL); }
    |   declaration ',' declaration_list    { $$ = new_ast("declaration", $1, new_ast(",", NULL, new_ast("declaration_list", $3, NULL))); }
    ;

assignment_list:    assignment              { $$ = new_ast("assignment", $1, NULL); }
    |   assignment ',' assignment_list      { $$ = new_ast("assignment", $1, new_ast(",", NULL, new_ast("assignment_list", $3, NULL))); }
    ;

flux:   if                                  { $$ = new_ast("if", $1, NULL); }
    |   switch                              { $$ = new_ast("switch", $1, NULL); }
    |   while                               { $$ = new_ast("while", $1, NULL); }
    |   do                                  { $$ = new_ast("do", $1, NULL); }
    |   for                                 { $$ = new_ast("for", $1, NULL); }
    ;

if:     '?' '(' expr ')' optional_block elseif else     { $$ = new_ast("?", NULL, new_ast("(", NULL, new_ast("expr", $3, new_ast(")", NULL, new_ast("optional_block", $5, new_ast("elseif", $6, new_ast("else", $7, NULL))))))); }
    |   '?' '(' error ')' optional_block elseif else    { $$ = new_ast("?", NULL, new_ast("(", NULL, new_ast("error", NULL, new_ast(")", NULL, new_ast("optional_block", $5, new_ast("elseif", $6, new_ast("else", $7, NULL))))))); }
    ;

elseif: /* nothing */                                   { $$ = new_ast("ϵ", NULL, NULL); }
    |   '$' '(' expr ')' optional_block elseif          { $$ = new_ast("$", NULL, new_ast("(", NULL, new_ast("expr", $3, new_ast(")", NULL, new_ast("optional_block", $5, new_ast("elseif", $6, NULL)))))); }
    |   '$' '(' error ')' optional_block elseif         { $$ = new_ast("$", NULL, new_ast("(", NULL, new_ast("error", NULL, new_ast(")", NULL, new_ast("optional_block", $5, new_ast("elseif", $6, NULL)))))); }
    ;

else:   /* nothing */                                   { $$ = new_ast("ϵ", NULL, NULL); }
    |   ':' optional_block                              { $$ = new_ast(":", NULL, new_ast("optional_block", $2, NULL)); }
    ;

switch: '#' '{' switch_body '}'                         { $$ = new_ast("#", NULL, new_ast("{", NULL, new_ast("switch_body", $3, new_ast("}", NULL, NULL)))); }
    |   '#' '{' error '}'                               { $$ = new_ast("#", NULL, new_ast("{", NULL, new_ast("error", NULL, new_ast("}", NULL, NULL)))); }
    ;

switch_body:    /* nothing */                           { $$ = new_ast("ϵ", NULL, NULL); }
    |   value ':' statement switch_body                 { $$ = new_ast("value", $1, new_ast(":", NULL, new_ast("statement", $3, new_ast("switch_body", $4, NULL)))); }
    ;

while:  'W' '(' expr ')' optional_block else            { $$ = new_ast("W", NULL, new_ast("(", NULL, new_ast("expr", $3, new_ast(")", NULL, new_ast("optional_block", $5, new_ast("else", $6, NULL)))))); }
    |   'W' '(' error ')' optional_block else           { $$ = new_ast("W", NULL, new_ast("(", NULL, new_ast("error", NULL, new_ast(")", NULL, new_ast("optional_block", $5, new_ast("else", $6, NULL)))))); }
    ;

do:     'O' '{' block '}' while                         { $$ = new_ast("O", NULL, new_ast("{", NULL, new_ast("block", $3, new_ast("}", NULL, new_ast("while", $5, NULL))))); }
    ;

for:    'F' '(' expr ')' optional_block else                                            { $$ = new_ast("F", NULL, new_ast("(", NULL, new_ast("expr", $3, new_ast(")", NULL, new_ast("optional_block", $5, new_ast("else", $6, NULL)))))); }
    |   'F' '(' INTEGER ';' expr ';' INTEGER ')' optional_block else                    { $$ = new_ast("F", NULL, new_ast("(", NULL, new_ast($3, NULL, new_ast(";", NULL, new_ast("expr", $5, new_ast(";", NULL, new_ast($7, NULL, new_ast(")", NULL, new_ast("optional_block", $9, new_ast("else", $10, NULL)))))))))); }
    |   'F' '(' declaration_list ';' expr ';' assignment_list ')' optional_block else   { $$ = new_ast("F", NULL, new_ast("(", NULL, new_ast("declaration_list", $3, new_ast(";", NULL, new_ast("expr", $5, new_ast(";", NULL, new_ast("assignment_list", $5, new_ast(")", NULL, new_ast("optional_block", $9, new_ast("else", $10, NULL)))))))))); }
    |   'F' '(' error ')' optional_block else                                           { $$ = new_ast("F", NULL, new_ast("(", NULL, new_ast("error", NULL, new_ast(")", NULL, new_ast("optional_block", $5, new_ast("else", $6, NULL)))))); }
    ;

function:   type ID '(' declaration_list ')' optional_block                             { $$ = new_ast("type", $1, new_ast($2, NULL, new_ast("(", NULL, new_ast("declaration_list", $4, new_ast(")", NULL, new_ast("optional_block", $6, NULL)))))); }
    |   type ID '(' error ')' optional_block                                            { $$ = new_ast("type", $1, new_ast($2, NULL, new_ast("(", NULL, new_ast("error", NULL, new_ast(")", NULL, new_ast("optional_block", $6, NULL)))))); }
    ;

%%

static void location_print(FILE *out, const YYLTYPE* loc) {
    fprintf (out, "%d.%d", loc->first_line, loc->first_column - 1);
    // int end_col = 0 != loc->last_column ? loc->last_column - 1 : 0;
    if (loc->first_line < loc->last_line) fprintf (out, "-%d.%d", loc->last_line, loc->last_column);
    else if (loc->first_column < loc->last_column) fprintf (out, "-%d", loc->last_column);
}

void yyerror (const YYLTYPE* loc, const user_context* uctx, const char *s) {
    location_print(stderr, loc);
    fprintf (stderr, ": %s\n", s);
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
    {
        fprintf(stderr, "%5d | %s\n", loc->first_line, uctx->line);
        fprintf(stderr, "%5s | %*s", "", loc->first_column - 1, "^");
        for (int i = loc->last_column - loc->first_column - 1; 0 <= i; --i) putc(i != 0? '~':'^', stderr);
        putc('\n', stderr);
    }
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
    bool do_dot = false;
    yyin = stdin;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-p") == 0) yydebug = 1;
        else if (strcmp(argv[i], "-d") == 0) do_dot = true;
        else {
            printf("Compiling %s\n", argv[i]);
            yyin = fopen(argv[i], "r");
        } 
    }

    user_context* uctx = init_uctx();

	do {
		yyparse(uctx);
	} while(!feof(yyin));

    free_uctx(uctx);

    if (do_dot) system("dot -Tpng verb_ast.dot -o ast.png");
	return 0;
}