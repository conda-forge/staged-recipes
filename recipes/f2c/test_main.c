#include "f2c.h"

integer s_wsle(cilist *);

integer do_lio(integer *, integer *, char *, ftnlen);

integer e_wsle(void);

int main (void) {

  integer one = 1;
  integer nine = 9;

  cilist io = {0, 6, 0, 0, 0};

  s_wsle (&io);

  do_lio (&nine, &one, "Hello, World!", (ftnlen) 13);

  e_wsle ();

  return 0;
}
