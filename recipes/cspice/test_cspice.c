#include <stdio.h>
#include "cspice/SpiceUsr.h"

int main ()
{
    printf ("One radian in degrees: %11.6f\n", dpr_c() * 1.0);
    return 0;
}
