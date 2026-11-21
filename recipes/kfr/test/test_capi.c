/* The C API is the only shared library of the package. */
#include <kfr/capi.h>

#include <stdio.h>

int main(void)
{
    printf("%s, archs: %s\n", kfr_version_string(), kfr_enabled_archs());
    return kfr_version() == 0;
}
