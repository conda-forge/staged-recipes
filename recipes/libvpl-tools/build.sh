set -ex

mkdir build
pushd build

cmake ${CMAKE_ARGS} \
    -DENABLE_WAYLAND=OFF \
    ..

make -j${CPU_COUNT}

make install
