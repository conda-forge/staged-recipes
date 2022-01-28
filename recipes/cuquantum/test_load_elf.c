#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

int main(int argc, char** argv) {
    void* handle;
    char* full_lib;

    if (argc != 2) {
        fprintf(stderr, "usage: test_load_elf mylib.so\n");
        exit(EXIT_FAILURE);
    }
    full_lib = argv[1];

    handle = dlopen(full_lib, RTLD_LAZY);
    if (!handle) {
        fprintf(stderr, "error: %s\n", dlerror());
        exit(EXIT_FAILURE);
    } else {
        printf("success: %s\n", full_lib);
        dlclose(handle);
    }

    return EXIT_SUCCESS;
}
