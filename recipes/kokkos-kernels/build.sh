
cmake -S ${SRC_DIR} -B build \
-GNinja \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=$PREFIX \
-DCMAKE_INSTALL_LIBDIR=lib \
-DBUILD_SHARED_LIBS=ON \
-DKokkosKernels_INSTALL_TESTING=OFF

cmake --build build -j $CPU_COUNT

cmake --install build

cmake -B build \
-DKokkosKernels_INSTALL_TESTING=ON

cmake --build build
