#!/bin/bash
set -e

# see https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots
# from https://github.com/conda-forge/libnetcdf-feedstock/blob/master/recipe/
declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
  export LDFLAGS=$(echo "${LDFLAGS}" | sed "s/-Wl,-dead_strip_dylibs//g")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

BLD="build"
mkdir -p "$BLD"

cmake -H"$SRC_DIR/source" -B"$BLD" \
     ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_INSTALL_LIBDIR="$PREFIX/lib" \
    -DBUILD_SHARED_LIBS=BOTH \
    -Deccodes_DIR="$PREFIX/lib/cmake/eccodes" \
    -Dmi-cpptest_DIR="$PREFIX/lib/cmake/mi-cpptest" \
    -Dmi-programoptions_DIR="$PREFIX/lib/cmake/mi-programoptions" \
    -Dpybind11_DIR="$PREFIX/share/cmake/pybind11" \
    -DTEST_EXTRADATA_DIR="$SRC_DIR/testdata" \
    -DPYTHON_EXECUTABLE="$PYTHON" \
    -DENABLE_FIMEX_VERSIONNUMBERED=NO \
    -DENABLE_ECCODES=YES \
    -DENABLE_LOG4CPP=YES \
    -DENABLE_FELT=YES \
    -DENABLE_FORTRAN=YES \
    -DENABLE_PRORADXML=NO \
    -DENABLE_FIMEX_OMP=YES \
    -DENABLE_PYTHON=YES \
    ${CMAKE_PLATFORM_FLAGS[@]}

cmake --build "$BLD" --target "all"

export CTEST_OUTPUT_ON_FAILURE="1"
cmake --build "$BLD" --target "test"

cmake --build "$BLD" --target "install"
