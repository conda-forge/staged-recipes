/*
 * NQP Wrapper - Handles binary patching artifacts in conda/rattler-build packages
 *
 * PURPOSE:
 * This wrapper fixes a critical issue with NQP's --show-config output when the binary
 * has been processed by rattler-build's relocatability patching system.
 *
 * THE PROBLEM:
 * When rattler-build creates relocatable packages, it patches hardcoded paths in binaries.
 * If the replacement path is shorter than the original, the remaining space gets filled
 * with null bytes to avoid corrupting adjacent data in the binary.
 *
 * In NQP's case, configuration strings like "nqp::libdir" get stored in the binary and
 * when the path is shortened during relocation patching, it ends up with ~172 null bytes
 * embedded in the middle of the configuration output.
 *
 * THE IMPACT:
 * When NQP's --show-config is used by build systems (like Rakudo's Configure.pl), the
 * null bytes break shell command parsing, causing syntax errors like:
 * "sh: -c: line 4: unexpected EOF while looking for matching ''"
 *
 * THE SOLUTION:
 * This wrapper intercepts --show-config calls and filters out null bytes and trailing
 * whitespace from the output, ensuring clean configuration data for downstream consumers.
 * All other NQP operations pass through unchanged for minimal performance impact.
 *
 * USAGE:
 * - Original NQP binary is renamed to "nqp-unwrapper"
 * - This wrapper is installed as "nqp"
 * - Only --show-config output is filtered; all other functionality is unaffected
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define BUFFER_SIZE 8192

/* Clean null bytes and trailing whitespace from buffer */
static size_t clean_buffer(char *buffer, size_t length) {
    size_t write_pos = 0;
    
    /* Remove null bytes */
    for (size_t i = 0; i < length; i++) {
        if (buffer[i] != '\0') {
            buffer[write_pos++] = buffer[i];
        }
    }
    
    /* Remove trailing whitespace from each line */
    size_t line_start = 0;
    for (size_t i = 0; i <= write_pos; i++) {
        if (i == write_pos || buffer[i] == '\n') {
            /* End of line or buffer - trim trailing whitespace */
            size_t line_end = i;
            while (line_end > line_start && 
                   (buffer[line_end - 1] == ' ' || buffer[line_end - 1] == '\t' || buffer[line_end - 1] == '\r')) {
                line_end--;
            }
            
            /* Move the line (including newline if present) */
            if (line_end != i) {
                if (i < write_pos) {
                    memmove(&buffer[line_end], &buffer[i], write_pos - i);
                    write_pos -= (i - line_end);
                    i = line_end;
                }
            }
            
            if (i < write_pos) {
                line_start = i + 1;
            }
        }
    }
    
    return write_pos;
}

/* Check if arguments contain --show-config */
static int has_show_config(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--show-config") == 0) {
            return 1;
        }
    }
    return 0;
}

/* Execute nqp-real with given arguments and return its output */
static int execute_and_filter(int argc, char *argv[]) {
    int pipefd[2];
    pid_t pid;
    
    if (pipe(pipefd) == -1) {
        perror("pipe");
        return 1;
    }
    
    pid = fork();
    if (pid == -1) {
        perror("fork");
        return 1;
    }
    
    if (pid == 0) {
        /* Child process */
        close(pipefd[0]); /* Close read end */
        dup2(pipefd[1], STDOUT_FILENO); /* Redirect stdout to pipe */
        dup2(pipefd[1], STDERR_FILENO); /* Redirect stderr to pipe */
        close(pipefd[1]);
        
        /* Replace argv[0] with nqp-unwrapper */
        argv[0] = "nqp-unwrapper";
        execvp("nqp-unwrapper", argv);
        
        /* If exec fails, try with full path */
        perror("execvp nqp-unwrapper");
        exit(1);
    } else {
        /* Parent process */
        close(pipefd[1]); /* Close write end */
        
        char buffer[BUFFER_SIZE];
        ssize_t bytes_read;
        
        while ((bytes_read = read(pipefd[0], buffer, sizeof(buffer) - 1)) > 0) {
            size_t cleaned_length = clean_buffer(buffer, (size_t)bytes_read);
            if (write(STDOUT_FILENO, buffer, cleaned_length) != (ssize_t)cleaned_length) {
                perror("write");
                break;
            }
        }
        
        close(pipefd[0]);
        
        int status;
        waitpid(pid, &status, 0);
        return WEXITSTATUS(status);
    }
}

int main(int argc, char *argv[]) {
    /* If --show-config is present, filter the output */
    if (has_show_config(argc, argv)) {
        return execute_and_filter(argc, argv);
    } else {
        /* For all other cases, just exec nqp-unwrapper directly */
        argv[0] = "nqp-unwrapper";
        execvp("nqp-unwrapper", argv);
        
        /* If exec fails */
        perror("execvp nqp-unwrapper");
        return 1;
    }
}