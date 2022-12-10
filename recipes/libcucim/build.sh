set -ex

mkdir build-release
cd build-release

cmake ${CMAKE_ARGS} \
    -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -S ..

make -j ${CPU_COUNT}
make install
