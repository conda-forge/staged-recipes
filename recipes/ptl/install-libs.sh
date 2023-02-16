#! /bin/bash
set -ex

cd build

cmake --install .

rm -r $PREFIX/include
rm -r $PREFIX/lib/cmake
rm -r $PREFIX/lib/pkgconfig
