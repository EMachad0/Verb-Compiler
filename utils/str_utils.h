#ifndef STR_UTILS_H
#define STR_UTILS_H

char* concat(const char *s1, const char *s2);
char* concat_many(int count, ...);
char* f_to_str(double v);
char* i_to_str(int v);

#endif