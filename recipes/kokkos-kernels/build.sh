
cmake -S ${SRC_DIR} -B build \
-GNinja \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=$PREFIX \
-DCMAKE_INSTALL_LIBDIR=lib \
-DBUILD_SHARED_LIBS=ON 

cmake --build build -j $CPU_COUNT

cmake --install build
