mkdir build
cd build

cmake \
-GNinja \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=$PREFIX \
-DCMAKE_INSTALL_LIBDIR=lib \
-DBUILD_SHARED_LIBS=ON \
${CMAKE_ARGS} \
-DKokkos_ENABLE_OPENMP=ON \
-DKokkos_ENABLE_EXAMPLES=OFF \
-DKokkos_ENABLE_SERIAL=ON \
${Kokkos_OPT_ARGS} \
${Kokkos_CUDA_ARGS} \
${Kokkos_TEST_ARGS} \
-S ${SRC_DIR}

cmake --build . -j $CPU_COUNT

# Tests will take approximately 8 minutes
ctest --output-on-failure

cmake --install .
