#!/bin/bash
mkdir build && cd build
../configure --prefix=${PREFIX} --with-zlib=${PREFIX}/lib 
make firefox-build
make firefox-install
make chrome-build
make chrome-install
