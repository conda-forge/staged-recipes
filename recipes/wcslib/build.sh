#! /bin/bash

IFS=$' \t\n' # workaround bad conda/toolchain interaction
set -e

configure_args=(
    --prefix=$PREFIX
    --enable-fortran
    --with-cfitsiolib=$PREFIX/lib
    --with-cfitsioinc=$PREFIX/include
#    --with-pgplotlib=$PREFIX/lib
#    --with-pgplotinc=$PREFIX/include/pgplot
)

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make # note: Makefile is not parallel-safe
make check
mkdir -p $PREFIX/share/man/man1
make install

cd $PREFIX
rm -rf share/doc
