#!/bin/bash

# if [[ $OSTYPE == 'darwin'* ]]; then
#     CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
# fi

# build SMS++
git submodule init
git submodule update

mkdir build
cd build
cmake ${CMAKE_ARGS} ..
cmake --build . --config Release -j ${CPU_COUNT}
cmake --install . --config Release --prefix "$PREFIX"
