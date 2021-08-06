# include <stdio.h>
# include <string.h>
# include "verb.tab.h"


void yyerror (const char *s) {
    fprintf (stderr, "%s\n", s);
}
