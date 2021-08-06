/* ========================================================================== */
/* ============================  %{ DIRETIVAS %}  =========================== */
/* ========================================================================== */

%{
#include <math.h>
#include "list.c"

int id = 0;
int cont_lin = 1;
int cont_col = 1;

list *l;

#define RESERVED_WORD 300
#define SIMBOLO 310
#define CHAR 320
#define STRING 330
#define OPERADOR 340
#define ATTOP 341
#define UNARYOP 342
#define BINARYOP 343
#define BITWISEOP 344
#define BOOLOP 345
#define NUMERO 350
#define FLOAT 351
#define INTEIRO 352
#define DIRETIVA 360
#define INCLUDE 361
#define DEFINE 362
#define LIB 370
#define TYPE 380
#define ID 390
#define UNIDENTIFIED 400
%}

/* ========================================================================== */
/* =============================  DEFINIÇÔES  =============================== */
/* ========================================================================== */

/* palavras reservadas */
TYPE      int|float|char|void
FOR       for
IF        if
RETURN    return
WHILE     while

/* variaveis */
ID        [a-zA-Z_][a-zA-Z0-9_]*

/* diretivas */
INCLUDE   \#include
DEFINE    \#define
LIB       [\"<]{ID}\.h[\">]

/* string */
SIMBOLO   [!#$%&*+,./:;>=<?@'^_`´~|\-\]\[\{\}()]
ESPECIAL  \\n|\\t|\\\\
CHARACTER .|{ESPECIAL}
CHAR      [']{CHARACTER}[']
STRING    ["]{CHARACTER}*["]


/* numeros */
DIGITO    [0-9]
INTEIRO   [\+\-]?{DIGITO}+
FLOAT     {INTEIRO}\.{DIGITO}*|{INTEIRO}*\.{DIGITO}+

/* operadores */
ATTOP     =
UNARYOP   \+\+|\-\-
BINARYOP  %|\+|\-|\*\/
BITWISEOP &|\||\^|<<|>>
BOOLOP    ==|!=|<=|>=|>|<|&&|\|\|

/* simbolos */
TERMINAL  ;
SEPARADOR ,
LPAREN    \(
RPAREN    \)
LCHAVE    \{
RCHAVE    \}
LCONCH    \[
RCONCH    \]

%%

{FOR}|{IF}|{RETURN}|{WHILE} {
                // printf("RESERVADA em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, RESERVED_WORD, "RESERVED_WORD", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{TERMINAL}|{SEPARADOR}|{LPAREN}|{RPAREN}|{LCHAVE}|{RCHAVE}|{LCONCH}|{RCONCH} {
                // printf("SIMBOLO   em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, SIMBOLO, "SIMBOLO", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{CHAR}      {
                // printf("CHAR      em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, CHAR, "CHAR", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{STRING}    {
                // printf("STRING    em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, STRING, "STRING", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{ATTOP}     {
                // printf("ATTOP     em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, ATTOP, "ATTOP", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{UNARYOP}   {
                // printf("UNARYOP   em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, UNARYOP, "UNARYOP", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{BINARYOP}  {
                // printf("BINARYOP  em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, BINARYOP, "BINARYOP", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{BITWISEOP} {
                // printf("BITWISEOP em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, BITWISEOP, "BITWISEOP", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{BOOLOP}    {
                // printf("BOOLOP    em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, BOOLOP, "BOOLOP", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }


{FLOAT}     {
                // printf("FLOAT     em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, FLOAT, "FLOAT", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{INTEIRO}   {
                // printf("INTEGER   em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, INTEIRO, "INTEIRO", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{INCLUDE}|{DEFINE} {
                // printf("DIRETIVAS em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, DIRETIVA, "DIRETIVA", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{LIB}       {
                // printf("LIB          em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, LIB, "LIB", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{TYPE}      {
                // printf("TYPE      em LIN %d, COL %d: %s \n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, TYPE, "TYPE", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

{ID}        {
                // printf("ID        em LIN %d, COL %d: %s\n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, ID, "ID", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

[ ]         ++cont_col;

\n          {
                ++cont_lin;
                cont_col = 1;
            }

\t          cont_col += 4;

.           {
                // printf("NAO RECON em LIN %d, COL %d: %s\n", cont_lin, cont_col, yytext);
                char* copy = malloc(strlen(yytext) * sizeof(char));
                item *new_item = item_create(id++, UNIDENTIFIED, "UNIDENTIFIED", cont_lin, cont_col, strcpy(copy, yytext));
                list_push_back(l, new_item);
                cont_col += strlen(yytext);
            }

%%

void print_tabela() {
    printf("%3s %5s %15s %3s %3s %s\n", "id", "token", "name", "lin", "col", "value");
    node *it = l->head;
    for (node *it = l->head; it != NULL; it = it->next) {
        item* i = it->value;
        printf("%3d %5d %15s %3d %3d %s\n", i->id, i->token, i->name, i->lin, i->col, i->value);
    }
}

int main(int argc, char ** argv) {
	++argv, --argc;

    l = list_create();

	if (argc > 0) yyin = fopen(argv[0], "r");
	else yyin = stdin;
	yylex();

    print_tabela();
	return 0;
}
