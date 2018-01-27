#! /bin/bash

set -e
set -o pipefail

configure_args=(
    --prefix=$PREFIX
)

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make # note: parallel build doesn't work reliably due to lack of rule defining creation of `giza.mod`

make check

ctests="
arrow
band
colour-index
error-bars
format-number
line-cap
line-style
points
qtext
rectangle
set-line-width
vector
window
"

for t in $ctests ; do
    echo /png |test/C/test-$t
done

./test/C/test-change-page <<EOF
/png
/pdf
/svg
EOF
./test/C/test-environment <<EOF
/png
/png
/png
/png
/png
/png
EOF
./test/C/test-pdf
./test/C/test-png
./test/C/test-svg
./test/F90/test-2D
./test/F90/test-fortran
# other fortran tests require X

make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf share/doc/giza
