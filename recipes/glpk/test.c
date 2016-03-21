/* Minimal test which prints out the GLPK version */
#include <stdio.h>
#include <stdlib.h>
#include "glpk.h"

int main(void) {
    printf("GLPK version %s\n", glp_version());
    return EXIT_SUCCESS;
}
