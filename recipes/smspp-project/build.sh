#!/bin/bash
git submodule init
git submodule update

mkdir build
cd build
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    ..
cmake --build . --config Release -j ${CPU_COUNT}
cmake --install . --config Release --prefix "$PREFIX"

chmod +x InvestmentBlock/test/InvestmentBlock_test
cp InvestmentBlock/test/InvestmentBlock_test "$PREFIX"/bin/InvestmentBlock_test
