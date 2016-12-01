
#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DMSGPACK_CXX11=YES \
    ..

make

make install
