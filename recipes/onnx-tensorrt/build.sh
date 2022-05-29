mkdir build
cd build
cmake ${CMAKE_ARGS}                    \
    -DONNX_USE_PROTOBUF_SHARED_LIBS=ON \
    -DBUILD_ONNX_PYTHON=OFF            \
    -DBUILD_SHARED_LIBS=ON \
    ..
make -j${CPU_COUNT}
make install
