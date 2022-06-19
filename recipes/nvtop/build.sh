set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DNVIDIA_SUPPORT=ON \
    -DAMDGPU_SUPPORT=ON \
    ..

make -j${CPU_COUNT}
make install
