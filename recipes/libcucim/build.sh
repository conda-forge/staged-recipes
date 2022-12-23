set -ex

mkdir build-release
cd build-release

# CUCIM_SUPPORT_GDS determines the use of libcufile
# I don't believe libcufile exists for cuda 11.2
cmake ${CMAKE_ARGS} \
    -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCUCIM_SUPPORT_GDS=OFF \
    -S ..

make -j ${CPU_COUNT}
make install
