set -ex

mkdir -p build
pushd build

cmake ${CMAKE_ARGS}                          \
    -DOJPH_BUILD_EXECUTABLES=ON              \
    ..

make -j ${CPU_COUNT}

make install
