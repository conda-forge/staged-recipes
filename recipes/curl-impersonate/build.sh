#!/bin/bash
mkdir build && cd build
../configure --prefix=${PREFIX} --with-zlib=${PREFIX}/lib 
make chrome-build
make chrome-checkbuild
make chrome-install
