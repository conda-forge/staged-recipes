cmake -B build -S $SRC_DIR -DCMAKE_INSTALL_PREFIX=$PREFIX $CMAKE_ARGS
cmake --build build
cmake --install build
