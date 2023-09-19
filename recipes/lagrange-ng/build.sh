#!/bin/bash

cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -Bbuild -H. -DBUILD_TESTS=ON
pushd build
make
make lagrange-test
popd

./bin/lagrange-test

mkdir -p $PREFIX/bin

cp bin/lagrange $PREFIX/bin
