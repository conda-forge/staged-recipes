set -ex

# don't use vendored happly (git submodule)
rm -rf deps/happly
mkdir -p deps/happly

cp $PREFIX/include/happly.h deps/happly/happly.h

mkdir build && cd build
cmake \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    ..

cmake --build . -j${CPU_COUNT}
cmake --build . --target install
