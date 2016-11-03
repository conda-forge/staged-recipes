// Minimal AMPL Example
// D. Orban <dominique.orban@gerad.ca>

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include "asl.h"
#include "nlp.h"
#include "getstub.h"

// Defines
#define CHR (char*)

// Global variables
ASL *asl;
fint showgrad = (fint)0;  // A command-line option (integer)
fint showname = (fint)0;  // A command-line option (integer)

keyword keywds[] = {  // MUST appear in alphabetical order!
  KW(CHR"showgrad", L_val, &showgrad, CHR"Evaluate gradient"),
  KW(CHR"showname", L_val, &showname, CHR"Display objective name")
};

Option_Info Oinfo = {
  CHR"miniampl", CHR"Mini AMPL Example",
  CHR"miniampl_options", keywds, nkeywds, 0,
  CHR"0.1", 0, 0, 0, 0, 0, 20091021
};


int main(int argc, char **argv) {

  FILE *nl;
  char *stub;
  fint nerror = (fint)0;
  int n_badvals = 0;
  real f;

  if( argc < 2 ) {
    fprintf(stderr, "Usage: %s stub\n", argv[0]);
    return 1;
  }

  // Read objectives and first derivative information.
  if( !(asl = ASL_alloc(ASL_read_fg)) ) exit(1);
  stub = getstub(&argv, &Oinfo);
  nl   = jac0dim(stub, (fint)strlen(stub));

  // Get command-line options.
  if (getopts(argv, &Oinfo)) exit(1);

  // Check command-line options.
  if( showgrad < 0 || showgrad > 1 ) {
    Printf("Invalid value for showgrad: %d\n", showgrad);
    n_badvals++;
  }
  if( showname < 0 || showname > 1 ) {
    Printf("Invalid value for showname: %d\n", showname);
    n_badvals++;
  }

  if(n_badvals) {
    Printf("Found %d errors in command-line options.\n", n_badvals);
    exit(1);
  }

  // Allocate memory for problem data.
  // The variables below must have precisely THESE names.
  X0    = (real*)Malloc(n_var * sizeof(real));  // Initial guess
  pi0   = (real*)Malloc(n_con * sizeof(real));  // Initial multipliers
  LUv   = (real*)Malloc(n_var * sizeof(real));  // Lower bounds on variables
  Uvx   = (real*)Malloc(n_var * sizeof(real));  // Upper bounds on variables
  LUrhs = (real*)Malloc(n_con * sizeof(real));  // Lower bounds on constraints
  Urhsx = (real*)Malloc(n_con * sizeof(real));  // Upper bounds on constraints
  want_xpi0 = 3;

  // Read in ASL structure - trap read errors
  if( fg_read(nl, 0) ) {
    fprintf(stderr, "Error fg-reading nl file\n");
    goto bailout;
  }

  if(showname) { // Display objective name if requested.
    Printf("Objective name: %s\n", obj_name(0));
  }

  // This "solver" outputs the objective function value at X0.
  f = objval(0, X0, &nerror);
  if(nerror) {
    fprintf(stderr, "Error while evaluating objective.\n");
    goto bailout;
  }
  Printf("f(x0) = %21.15e\n", f);

  // Optionally also output objective gradient at X0.
  if(showgrad) {
    real *g = (real*)malloc(n_var * sizeof(real));
    objgrd(0, X0, g, &nerror);
    Printf("g(x0) = [ ");
    for(int i=0; i<n_var; i++) Printf("%8.1e ", g[i]);
    Printf("]\n");
    free(g);
  }

  // Write solution to file. Here we just write the initial guess.
  Oinfo.wantsol = 9;  // Suppress message echo. Force .sol writing
  write_sol(CHR"And the winner is", X0, pi0, &Oinfo);

 bailout:
  // Free data structure. DO NOT use free() on X0, pi0, etc.
  ASL_free((ASL**)(&asl));

  return 0;
}
