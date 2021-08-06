%{
# include <stdio.h>
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
}

%printer { fprintf (yyo, "%s", $$); } <str> <op>;
%printer { fprintf (yyo, "%d", $$); } <int_val>;
%printer { fprintf (yyo, "%g", $$); } <flt_val>;

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

%type <str> ID STRING 
%type <int_val> INTEGER
%type <flt_val> FLOAT
%type <op> ATTOP BOOLOP CMPOP BITSHIFTOP UNARYOP EXPOP

%start block

%%

block:  /* nothing */
    |   statement block
    |   flux block
    |   function block
    ;

statement:  declaration ';'
    |   assignment ';'
    |   expr ';'
    |   error ';'
    ;

optional_block: statement
    |   '{' block '}'
    |   '{' error '}'
    ;

type:   'I'
    |   'D'
    |   'S'
    ;

value:  INTEGER
    |   FLOAT
    |   STRING
    ;    

expr:   value
    |   call
    |   expr '<' expr
    |   expr '>' expr
    |   expr BOOLOP expr
    |   expr '|' expr
    |   expr '^' expr
    |   expr '&' expr
    |   expr CMPOP expr
    |   expr BITSHIFTOP expr
    |   expr '+' expr
    |   expr '-' expr
    |   expr '*' expr
    |   expr '/' expr
    |   expr '%' expr
    |   '-' expr %prec UNARYOP
    |   '!' expr
    |   '~' expr
    |   expr EXPOP expr
    |   '(' expr ')'
    |   '(' error ')'
    ;

declaration:
    |   type ID
    |   type ID '=' expr
    ;

assignment: ID '=' expr
    |   ID ATTOP expr
    ;

call:   ID
    |   ID UNARYOP
    |   UNARYOP ID
    |   ID '(' ')'
    |   ID '(' expr_list ')'
    |   ID '(' error ')'
    ;

expr_list:  expr
    |   expr ',' expr_list
    ;

declaration_list:   declaration
    |   declaration ',' declaration_list
    ;

assignment_list:    assignment
    |   assignment ',' assignment_list
    ;

flux:   if
    |   switch
    |   while
    |   do
    |   for
    ;

if:     '?' '(' expr ')' optional_block elseif else
    |   '?' '(' error ')' optional_block elseif else
    ;

elseif: /* nothing */
    |   '$' '(' expr ')' optional_block elseif
    |   '$' '(' error ')' optional_block elseif
    ;

else:   /* nothing */
    |   ':' optional_block
    ;

switch: '#' '{' switch_body '}'
    |   '#' '{' error '}'
    ;

switch_body:    /* nothing */
    |   value ':' statement switch_body
    ;

while:  'W' '(' expr ')' optional_block else
    |   'W' '(' error ')' optional_block else
    ;

do: 'O' '{' block '}' while ;

for:    'F' '(' expr ')' optional_block else
    |   'F' '(' INTEGER ';' expr ';' INTEGER ')' optional_block else
    |   'F' '(' declaration_list ';' expr ';' assignment_list ')' optional_block else
    |   'F' '(' error ')' optional_block else
    ;

function:   type ID '(' declaration_list ')' optional_block
    |   type ID '(' error ')' optional_block
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
    if (argc == 2 && strcmp(argv[1], "-p") == 0) yydebug = 1;

    user_context* uctx = init_uctx();

    yyin = stdin;
	do {
		yyparse(uctx);
	} while(!feof(yyin));

    free_uctx(uctx);
	return 0;
}
