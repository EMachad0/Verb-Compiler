#ifndef STR_UTILS_H
#define STR_UTILS_H

#define RED "\033[1;31m"
#define RESET "\x1B[0m"
#define RED_ERROR "\033[1;31merror\x1B[0m"
#define YELLOW "\033[1;33m"

char* concat(const char *s1, const char *s2);
char* concat_many(int count, ...);
char* f_to_str(double v);
char* i_to_str(int v);

char *to_red(const char* text);
char *to_yellow(const char* text);

#endif