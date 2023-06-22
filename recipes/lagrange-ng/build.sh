#!/bin/bash

export MKLROOT=${PREFIX}
export CMAKE_PREFIX_PATH=${PREFIX}

cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -Bbuild -H.
pushd build
make
popd

mkdir -p $PREFIX/bin

cp bin/lagrange $PREFIX/bin

