#!/bin/bash

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
	CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
	CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

if [[ ${DEBUG_C} == yes ]]; then
  CMAKE_BUILD_TYPE=Debug
else
  CMAKE_BUILD_TYPE=Release
fi

mkdir geant4-build
cd geant4-build

cmake                                                          \
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}                   \
      -DCMAKE_INSTALL_PREFIX=${PREFIX}                         \
      -DBUILD_SHARED_LIBS=ON                                   \
      -DGEANT4_INSTALL_EXAMPLES=ON                             \
      -DGEANT4_INSTALL_DATA=ON                                 \
      -DGEANT4_BUILD_MULTITHREADED=ON                          \
      -DGEANT4_USE_GDML=ON                                     \
      ${CMAKE_PLATFORM_FLAGS[@]} \
      ${SRC_DIR}

make -j${CPU_COUNT} ${VERBOSE_CM}
make install -j${CPU_COUNT}
