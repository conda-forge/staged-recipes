#!/bin/bash

THIRDPARTY=(ASL Mumps)
for TP in ${THIRDPARTY[@]}
do
    cd ThirdParty/${TP} && ./get.${TP} && cd ../../
done

mkdir build
cd build

if [ $(uname -s) == 'Darwin' ]; then
  ../configure --with-blas="-Wl, -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread -liomp5 -lpthread -lm -ldl" CFLAGS=" -m64 -I$PREFIX/include" CXXFLAGS=" -m64 -I$PREFIX/include" --prefix=$PREFIX
else
  ../configure --with-blas='-Wl,--no-as-needed -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread -liomp5 -lpthread -lm -ldl' CFLAGS=' -m64 -I$PREFIX/include' CXXFLAGS=' -m64 -I$PREFIX/include' --prefix=$PREFIX
fi

make
make test
make install
