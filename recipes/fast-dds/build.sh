mkdir build
cd build

cmake \
    -G "Ninja" \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
    -DCMAKE_INSTALL_LIBDIR=lib \
    $SRC_DIR

cmake --build . --config Release --target install