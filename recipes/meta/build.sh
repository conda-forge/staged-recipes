#!/bin/bash

set -e
set -x

# Remove unused variables and ensure consistency
unset LD LINK ARCH

# Set RPATH to use $ORIGIN
# export LDFLAGS="-L$PREFIX/lib"
# export CXXFLAGS="-idirafter $PREFIX/include"

export LDFLAGS="-Wl,-rpath,'$ORIGIN/../lib' -L$PREFIX/lib"
export CXXFLAGS="-idirafter $PREFIX/include"

export CMAKE_BUILD_WITH_INSTALL_RPATH=ON
export CMAKE_INSTALL_RPATH_USE_LINK_PATH=ON
export CMAKE_INSTALL_RPATH='$ORIGIN/../lib'


mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib"
mkdir -p "$PREFIX/share"

mkdir -p $SRC_DIR/build
cd $SRC_DIR/build

cmake -S $SRC_DIR -B $SRC_DIR/build  \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_MODULE_PATH=$PREFIX/share/cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_RPATH=$CMAKE_INSTALL_RPATH \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=$CMAKE_BUILD_WITH_INSTALL_RPATH #\
    # -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=FALSE

cmake --build . --config Release
cmake --install .

rm -rf $SRC_DIR/build

# Install MeTA package
cd ${SRC_DIR}
${PYTHON} -m pip install . --no-deps -vv
