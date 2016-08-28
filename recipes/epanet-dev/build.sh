#!/bin/bash
mkdir build
cd build

cmake ..
make -j $CPU_COUNT

mkdir -p "${PREFIX}/lib" "${PREFIX}/bin"
if [ `uname` == Linux ]; then
   cp lib/*.so "${PREFIX}/lib"
fi

if [ `uname` == Darwin ]; then
   cp lib/*.dylib "${PREFIX}/lib"
fi

cp bin/run-epanet3 "${PREFIX}/bin"
