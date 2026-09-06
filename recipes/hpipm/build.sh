#!/bin/sh

rm -rf build
mkdir build
cd build

# HPIPM_TARGET is set in the recipe.yaml's
# script_env section, depending on the microarch
# level being built
cmake ${CMAKE_ARGS} -GNinja .. \
      -DHPIPM_FIND_BLASFEO:BOOL=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      -DHPIPM_TESTING:BOOL=ON \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DTARGET=${HPIPM_TARGET}

cmake --build . --config Release
cmake --build . --config Release --target install

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release
fi
