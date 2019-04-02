#!/bin/bash
declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
	CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
	CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

cmake ${CMAKE_PLATFORM_FLAGS[@]} ${PREFIX}/share/Geant4-${PKG_VERSION}/examples/basic/B1
make
source ${PREFIX}/bin/geant4.sh
./exampleB1 run2.mac
