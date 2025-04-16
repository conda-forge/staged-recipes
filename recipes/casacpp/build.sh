#! /bin/bash

set -xeuo pipefail

cmake_args=(
    $CMAKE_ARGS
    -GNinja
    -DCASACPP_VERSION=$PKG_VERSION
)

if [ $(uname) = Darwin ] ; then
    linkflags="-Wl,-rpath,$PREFIX/lib $LDFLAGS"

    cmake_args+=(
        -Darch=darwin64
        -Darchflag=x86_64
        -DCMAKE_Fortran_COMPILER=$FC
        # Make sure to get Conda versions of libraries:
        -DLIBXML2_ROOT_DIR=$PREFIX
        -DLIBXSLT_ROOT_DIR=$PREFIX
    )
else
    linkflags="-Wl,-rpath-link,$PREFIX/lib $LDFLAGS"
fi

cmake_args+=(
    -DCMAKE_EXE_LINKER_FLAGS="$linkflags"
    -DCMAKE_MODULE_LINKER_FLAGS="$linkflags"
    -DCMAKE_SHARED_LINKER_FLAGS="$linkflags"
)

cd casatools/src/code
mkdir build
cd build
cmake "${cmake_args[@]}" ..
ninja -j$CPU_COUNT
ninja install
