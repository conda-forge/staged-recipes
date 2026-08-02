#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja -DSPIRV_CROSS_SHARED=ON -DSPIRV_CROSS_ENABLE_TESTS=OFF .. 

cmake --build . --config Release
cmake --build . --config Release --target install

# The CLI requires the static targets at build time, but conda-forge should
# expose the supported shared C API rather than shipping static libraries.
find "${PREFIX}/lib" -maxdepth 1 -name 'libspirv-cross-*.a' -delete
