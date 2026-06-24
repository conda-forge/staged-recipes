#!/bin/sh

# See https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release
make -j $(($CPU_COUNT/2))

mkdir -p ${PREFIX}/bin/
mv fulgor ${PREFIX}/bin/
