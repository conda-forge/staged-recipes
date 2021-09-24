set -ex

mkdir build
cd build

cmake \
    ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=1 \
    ..

make -j${CPU_COUNT}
if [[ "${target_platform}" == "${build_platform}" ]]; then
    ctest
fi
make install
