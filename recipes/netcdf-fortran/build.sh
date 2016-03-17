#!/bin/bash

if [[ $(uname) == Linux ]]; then
yum install -y gcc-gfortran
fi

# See http://www.unidata.ucar.edu/support/help/MailArchives/netcdf/msg11939.html
if [ "$(uname)" == "Darwin" ]; then
    export DYLD_LIBRARY_PATH=${PREFIX}/lib
fi

CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib ./configure --prefix=$PREFIX

make
make check
make install
