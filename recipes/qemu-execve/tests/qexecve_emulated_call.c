#include <stdio.h>
#include <unistd.h>

int main() {
    char *args[] = {"./test", NULL}; // Command and arguments
    char *envp[] = {NULL}; // Environment variables (can be empty)

    printf("Executing: './test'...\n");

    if (execve("./test", args, envp) == -1) {
        perror("execve failed");
        return 1;
    }

    // This code will not be reached if execve succeeds
    return 0;
}