set -ex
mkdir build
cd build

# Debian seems to put the include headers in its own zopfli directory
cmake -LAH                                                                \
    -DCMAKE_BUILD_TYPE="Release"                                          \
    -DCMAKE_PREFIX_PATH=${PREFIX}                                         \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}                                      \
    -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include/zopfli                   \
    -DCMAKE_INSTALL_LIBDIR="lib"                                          \
    -DBUILD_SHARED_LIBS=1                                                 \
    -DZOPFLI_BUILD_SHARED=1                                               \
    ..

make -j${CPU_COUNT}
make install
