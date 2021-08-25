%option noyywrap
%{
#include "../ast/ast.h"
#include "../output/verb.tab.h"
%}

/* single character ops */
SCO             \;|\$|\:|\,|\(|\)|\{|\}|\[|\]

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

/* comments */
LINE_COMMENT    \/\/[^\n]*
BLOCK_COMMENT   \/\*[^*]*\*\/

%%

{SCO}           {   yylloc->first_column = ++yylloc->last_column;
                    strcat(uctx->line, yytext);
                    return yytext[0]; 
                }

{KEYWORD}       {   yylloc->first_column = ++yylloc->last_column;
                    strcat(uctx->line, yytext);
                    return yytext[0]; 
                }

{ID}            {   yylval->str = strdup(yytext); 
                    yylloc->first_column = yylloc->last_column + 1; 
                    yylloc->last_column += strlen(yytext);
                    strcat(uctx->line, yytext);
                    return ID; 
                }

{INTEIRO}       {   yylval->str = strdup(yytext);
                    strcat(uctx->line, yytext);
                    yylloc->first_column = yylloc->last_column + 1;
                    yylloc->last_column += strlen(yytext);
                    return INTEGER;
                }

{FLUTUANTE}     {   yylval->str = strdup(yytext); 
                    yylloc->first_column = yylloc->last_column + 1; 
                    yylloc->last_column += strlen(yytext);
                    strcat(uctx->line, yytext);
                    return FLOAT; 
                }

{TEXTO}         {   yylval->str = strdup(yytext); 
                    yylloc->first_column = yylloc->last_column + 1; 
                    yylloc->last_column += strlen(yytext);
                    strcat(uctx->line, yytext);
                    return STRING; 
                }

{EXP_OP}        {   yylval->op = strdup(yytext);
                    yylloc->first_column = yylloc->last_column + 1;
                    yylloc->last_column += strlen(yytext);
                    strcat(uctx->line, yytext);
                    return EXPOP; 
                }

{UNARY_OP}      {   yylval->op = strdup(yytext); 
                    yylloc->first_column = yylloc->last_column + 1;
                    yylloc->last_column += strlen(yytext);
                    strcat(uctx->line, yytext);
                    return UNARYOP; 
                }

{BITSHIFT_OP}   {   yylval->op = strdup(yytext); 
                    yylloc->first_column = yylloc->last_column + 1; 
                    yylloc->last_column += strlen(yytext); 
                    strcat(uctx->line, yytext);
                    return BITSHIFTOP;
                }

{CMP_OP}        {   yylval->op = strdup(yytext); 
                    yylloc->first_column = yylloc->last_column + 1; 
                    yylloc->last_column += strlen(yytext);
                    strcat(uctx->line, yytext);
                    return CMPOP; 
                }

{BOOL_OP}       {   yylval->op = strdup(yytext); 
                    yylloc->first_column = yylloc->last_column + 1; 
                    yylloc->last_column += strlen(yytext);
                    strcat(uctx->line, yytext);
                    return BOOLOP;
                }

{ATT_OP}        {   yylval->op = strdup(yytext); 
                    yylloc->first_column = yylloc->last_column + 1; 
                    yylloc->last_column += strlen(yytext);
                    strcat(uctx->line, yytext);
                    return ATTOP; 
                }

{SCO_OP}        {   yylloc->first_column = ++yylloc->last_column;
                    strcat(uctx->line, yytext);
                    return yytext[0];
                }

{LINE_COMMENT}  {   yylloc->first_column = yylloc->last_column + 1; 
                    yylloc->last_column += strlen(yytext);
                    strcat(uctx->line, yytext);
                }

{BLOCK_COMMENT} {   char* token = strtok(yytext, "\n");
                    yylloc->first_column = yylloc->last_column + 1;
                    yylloc->last_column += strlen(token);
                    strcat(uctx->line, token);
                    while(1) {
                        token = strtok(NULL, "\n");
                        if (token == NULL) break;
                        yylloc->first_line = ++yylloc->last_line;
                        yylloc->first_column = 1;
                        yylloc->last_column = 1 + strlen(token);
                        strcpy(uctx->line, token);
                    }
                }

\r

\n              {   yylloc->first_column = yylloc->last_column = 1;
                    yylloc->first_line = ++yylloc->last_line;
                    uctx->line[0] = '\0';
                }
                
[ ]             {   yylloc->first_column = ++yylloc->last_column;
                    strcat(uctx->line, yytext);
                }
    
.               {   yylloc->first_column = ++yylloc->last_column;
                    strcat(uctx->line, yytext);
                    // return YYUNDEF;
                    char error[] = "Lexical Error, Unexpected '%c'";
                    sprintf(error, error, yytext[0]);
                    yyerror(yylloc, uctx, error);
                    return YYerror;
                }

%%