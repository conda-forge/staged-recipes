#!/bin/bash

CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_TESTING=OFF"

# Ensure we build a release
CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # CFLAGS
    # JRG: Had to add -ldl to prevent linking errors (dlopen, etc)
    MINIMAL_CFLAGS+=" -g -O3 -ldl"
    CFLAGS+=" $MINIMAL_CFLAGS"
    CXXFLAGS+=" $MINIMAL_CFLAGS"
    LDFLAGS+=" $LDPATHFLAGS"

    # From https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots
    CMAKE_FLAGS+=" -DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross-linux.cmake"
    # Use GCC
    CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"


elif [[ "$OSTYPE" == "darwin"* ]]; then
    # conda-build MACOSX_DEPLOYMENT_TARGET must be exported as an environment variable to override 10.7 default
    # cc: https://github.com/conda/conda-build/pull/1561
    export MACOSX_DEPLOYMENT_TARGET="10.13"
    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
    CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
fi


# Set location for FFTW3 on both linux and mac
CMAKE_FLAGS+=" -DFFTW_INCLUDES=${PREFIX}/include/"
CMAKE_FLAGS+=" -DFFTW_LIBRARY=${PREFIX}/lib/libfftw3f${SHLIB_EXT}"
CMAKE_FLAGS+=" -DFFTW_THREADS_LIBRARY=${PREFIX}/lib/libfftw3f_threads${SHLIB_EXT}"


# DEBUG
env | sort
echo "CMAKE_FLAGS:"
echo $CMAKE_FLAGS


# Build in subdirectory and install.
mkdir build
cd build
cmake ${CMAKE_FLAGS} ${SRC_DIR}
make -j$CPU_COUNT
make -j$CPU_COUNT install PythonInstall

# Put examples into an appropriate subdirectory.
mkdir $PREFIX/share/openmm/
mv $PREFIX/examples $PREFIX/share/openmm/