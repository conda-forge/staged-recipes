set -ex

mkdir build
pushd build

cmake ${CMAKE_ARGS} ..
ninja -j${CPU_COUNT}
ninja install

popd
