mkdir build && cd build

# Configure step
cmake ${CMAKE_ARGS} .. \
    -G "Ninja" \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \

# Build step
cmake --build . --config Release
cmake --build . --config Release --target install