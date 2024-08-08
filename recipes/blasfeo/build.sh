#!/bin/sh

rm -rf build
mkdir build
cd build

# X64_INTEL_CORE is more and less aligned with nocona used 
# by conda-forge builds as of August 2024
cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DTARGET=X64_INTEL_CORE

cmake --build . --config Release
cmake --build . --config Release --target install

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release
fi
