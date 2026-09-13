cmake -B build -S $SRC_DIR -DBUILD_SHARED_LIBS=YES $CMAKE_ARGS
cmake --build build
cmake --install build
