#include <stdio.h>
#include "SpiceUsr.h"

int main ()
{
    printf ("One radian in degrees: %11.6f\n", dpr_c() * 1.0);
}
