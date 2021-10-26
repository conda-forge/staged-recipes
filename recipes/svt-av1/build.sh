#!/bin/bash

set -ex

if [[ $target_platform == linux-* ]]; then
    echo "target_link_libraries(SvtAv1EncApp rt)" >> Source/App/EncApp/CMakeLists.txt
fi

cd Build

cmake ${CMAKE_ARGS}              \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON     \
      -DNATIVE=OFF               \
      ..

make -j${CPU_COUNT} VERBOSE=1

make install
