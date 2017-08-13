/*
    R launcher for Windows

    To build/rebuild with mingw32, do this in the setuptools project directory:

       gcc -DGUI=0           -mno-cygwin -O -s -o setuptools/cli.exe launcher.c
       gcc -DGUI=1 -mwindows -mno-cygwin -O -s -o setuptools/gui.exe launcher.c
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <tchar.h>
#include <fcntl.h>
#include <process.h>

#define DEBUG 0

#if __SIZEOF_POINTER__ == 8
# define ARCH "x64"
#else
# define ARCH "i386"
#endif

int child_pid=0;


int fail(char *format, char *data)
{
    /* Print error message to stderr and return 2 */
    fprintf(stderr, format, data);
    return 2;
}


char *quoted(char *data)
{
    int i, ln = strlen(data), nb;

    /* We allocate twice as much space as needed to deal with worse-case
       of having to escape everything. */
    char *result = calloc(ln * 2 + 3, sizeof(char));
    char *presult = result;

    *presult++ = '"';
    for (nb=0, i=0; i < ln; i++)
    {
        if (data[i] == '\\')
            nb += 1;
        else if (data[i] == '"')
        {
            for (; nb > 0; nb--)
                *presult++ = '\\';
            *presult++ = '\\';
        }
        else
            nb = 0;
        *presult++ = data[i];
    }

    for (; nb > 0; nb--)        /* Deal w trailing slashes */
        *presult++ = '\\';

    *presult++ = '"';
    *presult++ = 0;
    return result;
}



void pass_control_to_child(DWORD control_type)
{
    /*
     * distribute-issue207
     * passes the control event to child process (Python)
     */
    if (!child_pid) {
        return;
    }
    GenerateConsoleCtrlEvent(child_pid, 0);
}


BOOL control_handler(DWORD control_type)
{
    /*
     * distribute-issue207
     * control event handler callback function
     */
    switch (control_type) {
        case CTRL_C_EVENT:
            pass_control_to_child(0);
            break;
    }
    return TRUE;
}


int create_and_wait_for_subprocess(char* command) {
    /*
     * distribute-issue207
     * launches child process (Python)
     */
    DWORD return_value = 0;
    LPSTR commandline = command;
    STARTUPINFOA s_info;
    PROCESS_INFORMATION p_info;
    ZeroMemory(&p_info, sizeof(p_info));
    ZeroMemory(&s_info, sizeof(s_info));
    s_info.cb = sizeof(STARTUPINFO);
    // set-up control handler callback funciotn
    SetConsoleCtrlHandler((PHANDLER_ROUTINE) control_handler, TRUE);
    if (!CreateProcessA(NULL, commandline, NULL, NULL, TRUE, 0, NULL,
                        NULL, &s_info, &p_info))
    {
        fprintf(stderr, "failed to create process.\n");
        return 0;
    }
    child_pid = p_info.dwProcessId;
    // wait for Python to exit
    WaitForSingleObject(p_info.hProcess, INFINITE);
    if (!GetExitCodeProcess(p_info.hProcess, &return_value))
    {
        fprintf(stderr, "failed to get exit code from process.\n");
        return 0;
    }
    return return_value;
}


char* join_executable_and_args(char *executable, char **args, int argc)
{
    /*
     * distribute-issue207
     * CreateProcess needs a long string of the executable and command-line arguments,
     * so we need to convert it from the args that was built
     */
    int len, counter;
    char* cmdline;

    len = strlen(executable) + 2;
    for (counter=1; counter<argc; counter++)
    {
        len += strlen(args[counter]) + 1;
    }

    cmdline = (char *) calloc(len, sizeof(char));
    sprintf(cmdline, "%s", executable);
    len=strlen(executable);
    for (counter=1; counter<argc; counter++) {
        sprintf(cmdline+len, " %s", args[counter]);
        len += strlen(args[counter]) + 1;
    }
    return cmdline;
}


int run(int argc, char **argv, int is_gui)
{
    char path[MAX_PATH], newpath[MAX_PATH];
    char *PATH, *newPATH;
    char **newargs, **newargsp; /* argument array for exec */
    char *fn, *end;     /* working pointers for string manipulation */
    char *cmdline;
    int i;              /* loop counter */

    /* compute script name from our .exe name*/
    GetModuleFileNameA(NULL, path, sizeof(path));

    fn = path + strlen(path);
    while (fn > path && *fn != '\\')
        fn--;
    fn++;
    end = fn - 2;
    while (end > path && *end != '\\')
        end--;
    *end = '\0';

    /* This is only temporary until {Ana,Mini,}conda activate does
       the job for us and can be assumed to have been rolled out.. */
    PATH = getenv("PATH");
    if (PATH != NULL)
    {
        #define MINGW_W64_PATH "\\Library\\mingw-w64\\bin"
        #define MSYS2_PATH     "\\Library\\usr\\bin"
        if (!strstr(PATH, MINGW_W64_PATH) ||
            !strstr(PATH, MSYS2_PATH))
        {
            size_t newPATHsize = 5 + 1 + strlen(PATH); /* PATH= and NULL terminator. */
            newPATHsize += strlen(path) + strlen(MINGW_W64_PATH) + 1;
            newPATHsize += strlen(path) + strlen(MSYS2_PATH) + 1;
            newPATH = calloc(newPATHsize, sizeof(char));
            if (newPATH == NULL)
                return fail("Could not calloc new PATH (%s)", PATH);
            sprintf(newPATH, "PATH=%s" MINGW_W64_PATH ";%s" MSYS2_PATH ";%s", path, path, PATH);
            if (putenv(newPATH))
                return fail("Could putenv newPATH (%s)", newPATH);
        }
    }
    strcpy(newpath, path);
    strcat(newpath, "\\R\\bin\\" ARCH "\\");
    strcat(newpath, fn);

#if DEBUG
    printf("==%s==\n", newpath);
#endif
    /* Argument array needs to be argc, plus 1 for null sentinel */
    newargs = (char **) calloc(argc + 1, sizeof(char *));
    newargsp = newargs;

    *newargsp++ = quoted(newpath);
    for (i = 1; i < argc; i++)
        *newargsp++ = quoted(argv[i]);

    *newargsp++ = NULL;

#if DEBUG
    for (i = 0; i <= argc; i++)
        printf("- %s\n", newargs[i]);
    printf("argc=%d\n", argc);
#endif

    if (is_gui) {
        /* Use exec, we don't need to wait for the GUI to finish */
        execv(newpath, (char * const *) (newargs));
        return fail("Could not exec %s", newpath); /* shouldn't get here! */
    }

    /*
     * distribute-issue207: using CreateProcessA instead of spawnv
     */
    cmdline = join_executable_and_args(newpath, newargs, argc);
    return create_and_wait_for_subprocess(cmdline);
}


int WINAPI WinMain(HINSTANCE hI, HINSTANCE hP, LPSTR lpCmd, int nShow)
{
    return run(__argc, __argv, GUI);
}


int main(int argc, char** argv)
{
    return run(argc, argv, GUI);
}
