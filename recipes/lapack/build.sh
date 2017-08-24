#!/bin/sh


mkdir build
cd build

# CMAKE_INSTALL_LIBDIR="lib" suppresses CentOS default of lib64 (conda expects lib)

cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR="lib" \
  -DBUILD_TESTING=ON \
  -DBUILD_SHARED_LIBS=ON \
  -DLAPACKE=ON \
  -DCBLAS=ON \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
  ..

make
ctest --output-on-failure
make install