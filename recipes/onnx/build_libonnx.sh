#!/bin/bash

mkdir build
cd build
    # -DCMAKE_CXX_STANDARD=17
cmake ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc \
    -DProtobuf_LIBRARY=$PREFIX/lib/libprotobuf${SHLIB_EXT} \
    -DProtobuf_INCLUDE_DIR:PATH=${PREFIX}/include \
    ..

make -j ${CPU_COUNT}
make install
