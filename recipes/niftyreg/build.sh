set -euxo pipefail

rm -rf build || true
mkdir -p build/
cd build

# eigen3 is expected in this subdir; otherwise a bundled one is extracted
mkdir -p ./third-party
ln -s ${PREFIX}/include/eigen3 ./third-party/eigen3

OUR_CMAKE_FLAGS=""
if [[ $target_platform == "osx-"* ]]; then
    OUR_CMAKE_FLAGS+="-DUSE_OPENMP=OFF"
fi

cmake ${SRC_DIR} \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    $OUR_CMAKE_FLAGS

make
make check
make install
