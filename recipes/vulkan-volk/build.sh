set -ex

mkdir build
pushd build

cmake .. \
    ${CMAKE_ARGS} \
    -DVOLK_INSTALL=ON \
    -DBUILD_SHARED_LIBS=ON

make -j${CPU_COUNT}
make install

popd
