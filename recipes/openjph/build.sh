set -ex

mkdir -p build
pushd build

# OJPH_BUILD_EXECUTABLES would require libtiff which creates a circular
# dependency
cmake ${CMAKE_ARGS}                          \
    -DOJPH_BUILD_EXECUTABLES=ON              \
    ..

make -j ${CPU_COUNT}

make install
