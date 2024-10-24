set -ex

cmake . \
    -B build \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    -D ARBORX_ENABLE_MPI=OFF \
    ${CUDA_ARGS} # only for CUDA-enabled Kokkos

cd build
make -j1 # to have consistent logging
make install
