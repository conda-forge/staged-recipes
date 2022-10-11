#!/usr/bin/env bash
set -x -e -o pipefail

cat << EOF > dummy.c
#include <stdio.h>
#include <stdlib.h>
#include "wcs.h"

int main() {
    pix2wcs(NULL, 0, 0, NULL, 0);
}
EOF

$CC -I$PREFIX/include dummy.c -lm $PREFIX/lib/libwcs.a
nm a.out | grep "T pix2wcs"
