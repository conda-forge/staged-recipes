#include <stdio.h>
#include <windows.h>
#include <string.h>
#include <stdlib.h>

/*
   IMP Python command line tools on Unix/Linux/Mac are typically named
   without a .py extension (e.g. 'myapp' not 'myapp.py') and rely on a
   #!/usr/bin/python line at the start of the file to tell the OS that
   they are Python files. This doesn't work on Windows though, since
   Windows relies on the file extension.

   Both Python and C++ command line tools in the IMP conda package are
   installed in Library\bin\. This directory is not in the PATH. Furthermore,
   they both pull in DLLs installed in either Library\bin\ or Library\lib\,
   and these directories are not in the PATH either (so Windows won't be able
   to find the DLLs).

   To remedy these problems, we provide this wrapper. Compile with
      cl app_wrapper.c shell32.lib
   then copy the resulting app_wrapper.exe to myapp.exe and install in
   the top-level Anaconda directory. Then a user should be able to simply
   type 'myapp', and the right C++ or Python tool will be run with the
   correct PATH set.
*/

/* Add the two given subdirectories of topdir to PATH */
static void add_to_path_env(const char *topdir, const char *subdir1,
                            const char *subdir2)
{
  char *new_path;
  char *orig_path = getenv("PATH");
  /*printf("%s\n", orig_path); */
  new_path = malloc(strlen(topdir) * 2 + strlen(subdir1) + strlen(subdir2)
                    + 8 + strlen(orig_path));
  strcpy(new_path, "PATH=");
  strcat(new_path, topdir);
  strcat(new_path, subdir1);
  strcat(new_path, ";");
  strcat(new_path, topdir);
  strcat(new_path, subdir2);
  strcat(new_path, ";");
  strcat(new_path, orig_path);
  /*printf("%s\n", new_path);*/
  putenv(new_path);
  /* Don't free new_path; it is now part of the environment */
}

/* Get full path to fname in topdir/subdir */
static char *get_new_full_path(const char *topdir, const char *subdir,
                               const char *fname)
{
  char *newpath = malloc(strlen(topdir) + strlen(subdir) + strlen(fname) + 1);
  strcpy(newpath, topdir);
  strcat(newpath, subdir);
  strcat(newpath, fname);
  return newpath;
}

/* Get full path to this binary */
static void get_full_path(char **dir, char **fname)
{
  char path[MAX_PATH * 2];
  size_t l;
  char *ch;
  DWORD ret = GetModuleFileName(NULL, path, MAX_PATH * 2);
  if (ret == 0) {
    fprintf(stderr, "Failed to get executable name, code %d\n", GetLastError());
    exit(1);
  }
  l = strlen(path);
  if (l > 4 && path[l - 4] == '.') {
    /* Remove extension */
    path[l-4] = '\0';
  }
  ch = strrchr(path, '\\');
  if (ch) {
    *ch = '\0';
    *fname = strdup(ch + 1);
  } else {
    *fname = strdup("");
  }
  *dir = strdup(path);
}

/* Find where the parameters start in the command line (skip past the
   executable name) */
static char *find_param_start(char *cmdline)
{
  BOOL in_quote = FALSE, in_space = FALSE;
  for (; *cmdline; cmdline++) {
    /* Ignore spaces that are quoted */
    if (*cmdline == ' ' && !in_quote) {
      in_space = TRUE;
    } else if (*cmdline == '"') {
      in_quote = !in_quote;
    }
    /* Return the first nonspace that follows a space */
    if (in_space && *cmdline != ' ') {
      break;
    }
  }
  return cmdline;
}

/* Convert original parameters into those that python.exe wants (i.e. prepend
   the name of the Python script) */
static char *make_python_parameters(const char *orig_param, const char *binary)
{
  char *param = malloc(strlen(orig_param) + strlen(binary) + 4);
  strcpy(param, "\"");
  strcat(param, binary);
  strcat(param, "\" ");
  strcat(param, orig_param);
  /*printf("python param %s\n", param);*/
  return param;
}

/* Get the full path to the Anaconda Python. */
static char* get_python_binary(const char *topdir)
{
  char *python = malloc(strlen(topdir) + 12);
  strcpy(python, topdir);
  strcat(python, "\\python.exe");
  return python;
}

/* Run the given binary, passing it the parameters we ourselves were given.
   If the binary is actually a Python script, be sure to run it with Python. */
static DWORD run_binary(const char *binary, const char *topdir, int is_python)
{
  SHELLEXECUTEINFO si;
  BOOL bResult;
  char *param, *python = NULL;
  param = strdup(GetCommandLine());

  ZeroMemory(&si, sizeof(SHELLEXECUTEINFO));
  si.cbSize = sizeof(SHELLEXECUTEINFO);
  /* Wait for the spawned process to finish, so that any output goes to the
     console *before* the next command prompt */
  si.fMask = SEE_MASK_NO_CONSOLE | SEE_MASK_NOASYNC | SEE_MASK_NOCLOSEPROCESS;
  if (is_python) {
    char *orig_param = param;
    python = get_python_binary(topdir);
    si.lpFile = python;
    param = make_python_parameters(find_param_start(param), binary);
    free(orig_param);
    si.lpParameters = param;
  } else {
    si.lpFile = binary;
    si.lpParameters = find_param_start(param);
  }
  si.nShow = SW_SHOWNA;
  bResult = ShellExecuteEx(&si);
  free(param);
  free(python);

  if (bResult) {
    if (si.hProcess) {
      DWORD exit_code;
      WaitForSingleObject(si.hProcess, INFINITE);
      GetExitCodeProcess(si.hProcess, &exit_code);
      CloseHandle(si.hProcess);
      return exit_code;
    }
  } else {
    fprintf(stderr, "Failed to start process, code %d\n", GetLastError());
    exit(1);
  }
  return 0;
}

int main(int argc, char *argv[]) {
  static const char *library_lib = "\\Library\\lib\\";
  static const char *library_bin = "\\Library\\bin\\";
  int is_python;
  char *dir, *fname, *new_full_path;
  DWORD return_code;

  get_full_path(&dir, &fname);
  /*printf("%s, %s\n", dir, fname);*/
  add_to_path_env(dir, library_lib, library_bin);
  new_full_path = get_new_full_path(dir, library_bin, fname);
  /* If file (without extension) exists, then it must be a Python script */
  is_python = (_access(new_full_path, 0) == 0);
  /*printf("new full path %s, %d\n", new_full_path, is_python);*/
  return_code = run_binary(new_full_path, dir, is_python);
  free(dir);
  free(fname);
  free(new_full_path);
  return return_code;
}
