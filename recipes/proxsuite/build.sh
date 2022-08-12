#!/bin/sh

if [ "$(uname)" == "Darwin" ]; then
  # for Mac OSX
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY -D_LIBCPP_USING_IF_EXISTS"
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=OFF \
      -DINSTALL_DOCUMENTATION:BOOL=ON \
      -DBUILD_PYTHON_INTERFACE:BOOL=ON \
      -DBUILD_WITH_VECTORIZATION_SUPPORT:BOOL=ON \
      -DPYTHON_EXECUTABLE=$PYTHON

make -j${CPU_COUNT}
make install
