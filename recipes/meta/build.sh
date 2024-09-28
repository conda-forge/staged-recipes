#!/bin/bash
set -e
set -x
unset LD LINK ARCH

export CXXFLAGS="-idirafter $PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LINKFLAGS="-L$PREFIX/lib -Wl,-rpath,${PREFIX}/lib"
# export EIGEN_CFLAGS="-idirafter $PREFIX/include/eigen3"

# export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/eigen3"

# export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
export CMAKE_INSTALL_RPATH="$PREFIX/lib"
export CMAKE_BUILD_WITH_INSTALL_RPATH=ON



# # Set RPATH to use $ORIGIN
# export LDFLAGS="-L$ORIGIN/../lib"
# export LINKFLAGS="-L$ORIGIN/../lib -Wl,-rpath,$ORIGIN/../lib"
# export CMAKE_INSTALL_RPATH='$ORIGIN/../lib'
# export CMAKE_BUILD_WITH_INSTALL_RPATH=ON

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
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=$CMAKE_BUILD_WITH_INSTALL_RPATH

cmake --build . --config Release
cmake --install .

rm -rf $SRC_DIR/build

# Install MeTA package
cd ${SRC_DIR}
${PYTHON} -m pip install . --no-deps -vv

