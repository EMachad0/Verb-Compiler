%option noyywrap
%{
# include "verb.h"
# include "verb.tab.h"

%}

/* single character ops */
SCO             \;|\:|\,|\(|\)|\{|\}|\[|\]

/* keywords */
KEYWORD         [DFIOSW?#]

/* variaveis */
ID              [a-z_][a-z0-9_]*

/* numeros */
DIGITO          [0-9]
INTEIRO         [\+\-]?{DIGITO}+
FLUTUANTE       {INTEIRO}\.{DIGITO}*|{INTEIRO}*\.{DIGITO}+

/* text */
CHARACTER       .
TEXTO           ["]{CHARACTER}*["]

/* operadores */
SCO_OP          [=|^&<>+\-*/%!~]
ATT_OP          ([+\-*/%&^|]|<<|>>|\*\*)=
BOOL_OP         \&\&|\|\|
CMP_OP          [=!<>]=
BITSHIFT_OP     <<|>>
UNARY_OP        \+\+|\-\-
EXP_OP          \*\*

%%

{SCO}           { return yytext[0]; }

{KEYWORD}       { return yytext[0]; }

{ID}            { yylval.str = strdup(yytext); return ID; }

{INTEIRO}       { yylval.int_val = atoi(yytext); return INTEGER; }

{FLUTUANTE}     { yylval.flt_val = atof(yytext); return FLOAT; }

{TEXTO}         { yylval.str = strdup(yytext); return STRING; }

{EXP_OP}        { yylval.op = strdup(yytext); return EXPOP; }
{UNARY_OP}      { yylval.op = strdup(yytext); return UNARYOP; }
{BITSHIFT_OP}   { yylval.op = strdup(yytext); return BITSHIFTOP; }
{CMP_OP}        { yylval.op = strdup(yytext); return CMPOP; }
{BOOL_OP}       { yylval.op = strdup(yytext); return BOOLOP; }
{ATT_OP}        { yylval.op = strdup(yytext); return ATTOP; }
{SCO_OP}        { return yytext[0]; }

\n

[ \t]

.               { 
                    return YYUNDEF;
                    char error[] = "(IE) Lexical Error, Unexpected '%c'";
                    sprintf(error, error, yytext[0]);
                    yyerror(error);
                    return YYerror;
                }

%%