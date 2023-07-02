set -ex
mkdir -p build
cd build

cmake ${CMAKE_ARGS}                  \
    -DCMAKE_BUILD_TYPE=Release       \
    -DSHADERC_SKIP_TESTS=ON          \
    -DSHADERC_SKIP_EXAMPLES=ON       \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    ..

make -j${CPU_COUNT}
make install
