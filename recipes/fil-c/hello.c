#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
    char *p = malloc(16);
    if (p == NULL) {
        return 1;
    }
    strcpy(p, "Fil-C");
    printf("Hello from %s!\n", p);
    free(p);
    return 0;
}
