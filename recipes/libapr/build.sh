set -euxo pipefail

rm -rf build || true
mkdir build
cd build

cmake ${SRC_DIR} ${CMAKE_ARGS} \
    -DAPR_INSTALL=OFF \
    -DAPR_BUILD_SHARED_LIB=ON \
    -DAPR_BUILD_STATIC_LIB=OFF \
    -DAPR_BUILD_EXAMPLES=OFF \
    -DAPR_USE_LIBTIFF=ON \
    -DAPR_TESTS=OFF \
    -DAPR_PREFER_EXTERNAL_GTEST=ON \
    -DAPR_PREFER_EXTERNAL_BLOSC=ON \
    -DAPR_USE_CUDA=OFF \
    -DAPR_USE_OPENMP=ON \
    -DAPR_BENCHMARK=OFF \
    -DAPR_DENOISE=OFF

make
make install
