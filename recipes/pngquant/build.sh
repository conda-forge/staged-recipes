#!/bin/bash
set -o errexit -o pipefail

if [[ ${target_platform} == osx-* ]]
then
    ./configure --prefix=$PREFIX --with-libimagequant=${PREIFIX}/lib
else
    ./configure --prefix=$PREFIX --with-openmp --with-libimagequant=${PREIFIX}/lib
fi

make -j$CPU_COUNT
make test
make install

