#include <stdio.h>
#include <execinfo.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>

void (*default_handler) (int);


void segfault_handler(int sig) {
  void *array[32];
  size_t size;

  // get void*'s for all entries on the stack
  size = backtrace(array, 32);

  // print out all the frames to stderr
  fprintf(stderr, "##################################################################################\n\n");
  fprintf(stderr, "Your program crashed with an error signal: %d\n\n", sig);
  fprintf(stderr, "This the trace of C functions being called\n(the first one or two may be part of the error handling):\n");
  fprintf(stderr, "##################################################################################\n\n");
  backtrace_symbols_fd(array, size, STDERR_FILENO);

  // Now do the default handler
  fprintf(stderr, "##################################################################################\n\n");
  fprintf(stderr, "\nAnd here is the python faulthandler report and trace:\n\n");
  default_handler(sig);
  fprintf(stderr, "##################################################################################\n\n");

  //Finally quit
  exit(1);
}


// Example function you can

int trigger_segfault_1(){
  int * x = (int*) -1;
  int y = *x;
  return y;
}

void trigger_segfault(){
  trigger_segfault_1();
}


void enable_combined_segfault_handler(){
  default_handler = signal(SIGSEGV, segfault_handler);   // install our handler
}
