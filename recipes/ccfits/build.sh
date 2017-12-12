#!/bin/bash

# cd CCfits

if [ "$(uname)" == "Darwin" ]; then

    export CC=clang
    export CXX=clang++

else

    export CC=${PREFIX}/bin/gcc
    export CXX=${PREFIX}/bin/g++

fi

mkdir build
cd build

cmake -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} -DBUILD_SHARED_LIBS=on ..

make
make install

# Remove the cookbook binary
rm -rf $PREFIX/bin/cookbook
