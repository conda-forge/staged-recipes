#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <command> [args...]\n", argv[0]);
        return 1;
    }

    pid_t pid = fork();
    if (pid == -1) {
        perror("fork failed");
        return 1;
    }

    if (pid == 0) {
        // Child process
        char *envp[] = {NULL}; // Environment variables (can be empty)
        char *exec_args[argc];
        for (int i = 1; i < argc; i++) {
            exec_args[i - 1] = argv[i];
        }
        exec_args[argc - 1] = NULL; // Null-terminate the array

        if (execve(exec_args[0], exec_args, envp) == -1) {
            perror("execve failed");
            return 1;
        }
    } else {
        // Parent process
        int status;
        waitpid(pid, &status, 0);
        if (WIFEXITED(status)) {
            printf("Child exited with status %d\n", WEXITSTATUS(status));
        } else {
            printf("Child did not exit successfully\n");
        }
    }

    return 0;
}