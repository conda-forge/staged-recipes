#!/bin/bash

set -ex

mkdir build
cd build
cmake -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DENABLE_TESTS=OFF \
      -DCMAKE_LIBRARY_PATH="${PREFIX}/lib" \
      -DCMAKE_INCLUDE_PATH="${PREFIX}/include" \
      -DWITH_FGT="${PREFIX}" \
      -DWITH_JSONCPP=OFF \
      -DWITH_STRICT_WARNINGS=ON \
      ..

# CircleCI offers two cores.
make -j $CPU_COUNT
make install
