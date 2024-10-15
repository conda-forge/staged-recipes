#!/bin/bash

rm -rf build
mkdir build
cd build

export CMAKE_NUM_THREADS=8
cmake $CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -DUSE_USHER=ON ..
make -j20

mkdir -p $PREFIX/lib
cp $(find . -name *.so*) $PREFIX/lib/

mkdir -p $PREFIX/bin
cp larch-usher $PREFIX/bin/larch-usher
cp larch-dagutil $PREFIX/bin/larch-dagutil
cp larch-dag2dot $PREFIX/bin/larch-dag2dot

if [[ ${LARCH_INCLUDE_TEST} == true ]]; then
    cp larch-test $PREFIX/bin/larch-test
fi
