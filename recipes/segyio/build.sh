mkdir build
cd build
cmake .. \
    -DPYTHON_EXECUTABLE=$PYTHON \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build . --config release --target install
