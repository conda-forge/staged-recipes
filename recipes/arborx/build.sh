set -ex

cmake . \
    -B build \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_EXTENSIONS=OFF \
    -DARBORX_ENABLE_MPI=OFF \
    ${CMAKE_ARGS} \
    ${CUDA_ARGS} # only for CUDA-enabled Kokkos

cd build
make -j1 # to have consistent logging

make install
