#include <stdio.h>
#include <asdf.h>
#include <asdf/gwcs/gwcs.h>

int main(void) {
    asdf_file_t *file = asdf_open("test.asdf", "r");
    asdf_gwcs_t *wcs = NULL;
    if (!file || asdf_get_gwcs(file, "wcs", &wcs) != ASDF_VALUE_OK)
        return 1;
    asdf_gwcs_eval_t *eval = asdf_gwcs_eval_create(file, wcs, NULL, NULL);
    double x = 1.5, y = 2.5;
    if (!eval || asdf_gwcs_eval_2d(eval, &x, &y, &x, &y, 1) != ASDF_GWCS_OK)
        return 1;
    printf("%g %g\n", x, y);
    return 0;
}
