#include <stdio.h>
#include <unistd.h>

int main() {
    char *args[] = {"/bin/ls", "-l", NULL}; // Command and arguments
    char *envp[] = {NULL}; // Environment variables (can be empty)

    printf("Executing x86_64: 'ls -l'...\n");

    if (execve("/bin/ls", args, envp) == -1) {
        perror("execve failed");
        return 1;
    }

    // This code will not be reached if execve succeeds
    return 0;
}