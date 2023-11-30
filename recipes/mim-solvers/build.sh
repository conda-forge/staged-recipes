#!/bin/sh

if [ "$(uname)" == "Darwin" ]; then
  # for Mac OSX
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build
cd build

cmake .. \
      ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DPYTHON_EXECUTABLE=$PYTHON

make -j${CPU_COUNT} 
make install
