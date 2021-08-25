#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

char* concat(const char *s1, const char *s2) {
    char *result = malloc(strlen(s1) + strlen(s2) + 1); // +1 for NULL
    return strcpy(stpcpy(result, s1), s2);
}

char* concat_many(int count, ...) {
    va_list ap;
    // Find required length to store merged string
    int len = 1; // +1 for NULL
    va_start(ap, count);
    for(int i = 0; i < count; i++) len += strlen(va_arg(ap, char*));
    va_end(ap);

    // Allocate memory to concat strings
    char *merged = calloc(sizeof(char), len);
    int null_pos = 0;

    // Actually concatenate strings
    va_start(ap, count);
    for(int i = 0; i < count; i++) {
        char *s = va_arg(ap, char*);
        strcpy(merged+null_pos, s);
        null_pos += strlen(s);
    }
    va_end(ap);

    return merged;
}