#!/bin/bash

set -ex


unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     flags="-D_GLIBCXX_USE_CXX11_ABI=0";;
    *)          flags=""
esac
echo ${machine}

CXXFLAGS="${flags}" cmake -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_LIBRARY_PATH="${PREFIX}/lib" \
      -DCMAKE_INCLUDE_PATH="${PREFIX}/include"

# CircleCI offers two cores.
make -j $CPU_COUNT
make install
