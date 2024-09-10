set -ex

mkdir build
pushd build

cmake .. \
    ${CMAKE_ARGS} \
    -DVOLK_INSTALL=ON

make -j${CPU_COUNT}
make install

popd
