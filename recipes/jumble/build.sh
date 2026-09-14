cmake -B build -S $SRC_DIR -DBUILD_SHARED_LIBS=YES $CMAKE_ARGS
cmake --build build --parallel ${CPU_COUNT}
cmake --install build
