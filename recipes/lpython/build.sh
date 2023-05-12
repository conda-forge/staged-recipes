#!/bin/bash

set -ex

export CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS -D_LIBCPP_DISABLE_AVAILABILITY"

./build0.sh
mkdir build
cd build
export LFORTRAN_CC=${CC}
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS_RELEASE="-Wall -Wextra -O3 -funroll-loops -DNDEBUG" \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DWITH_LLVM=yes \
    -DWITH_XEUS=yes \
    $SRC_DIR

make -j${CPU_COUNT}
make install
mkdir -p $PREFIX/share/lpython/lib/lpython/
mkdir -p $PREFIX/share/lpython/lib/impure/
cp ../src/runtime/*.py $PREFIX/share/lpython/lib/
cp ../src/runtime/lpython/*.py $PREFIX/share/lpython/lib/lpython/
cp ../src/libasr/runtime/lfortran_intrinsics.h $PREFIX/share/lpython/lib/impure
