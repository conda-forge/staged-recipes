#!/bin/sh

# bug 145
if test `uname` = "Linux"
then
  sed -e 's|/CMAKE/|/cmake/|' -i CBLAS/CMakeLists.txt
fi

# lapack_testing.py does not support py3k, correction sent
cp ${RECIPE_DIR}/lapack_testing.py .

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