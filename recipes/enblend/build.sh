set -ex

mkdir build
cd build

export LDFLAGS="$LDFLAGS -lrt"
export CXXFLAGS="$CXXFLAGS -lstdc++fs -lrt"

cmake \
    -DCMAKE_BUILD_TYPE="Release"                                          \
    -DCMAKE_PREFIX_PATH=${PREFIX}                                         \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}                                      \
    ..

make -j${CPU_COUNT}
make install
