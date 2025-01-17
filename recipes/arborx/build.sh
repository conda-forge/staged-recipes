set -ex

cmake \
    -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_CXX_EXTENSIONS=OFF \
    -DARBORX_ENABLE_MPI=OFF \
    -B build \
    -S  ${SRC_DIR}

cd build
cmake --build . -j1 # to have consistent logging

cmake --install .
