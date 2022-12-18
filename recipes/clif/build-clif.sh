#!/bin/bash
set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBUILD_SHARED_LIBS=ON \
    ..

cmake --build .
cmake --install .

# shift some generated artefacts where python build expects them, see
# https://github.com/google/clif/blob/v0.4.1/INSTALL.sh#L86-L90
cp ./clif/protos/ast_pb2.py ${SRC_DIR}/clif/protos/
cp ./clif/python/utils/proto_util.cc ${SRC_DIR}/clif/python/utils/
cp ./clif/python/utils/proto_util_clif.h ${SRC_DIR}/clif/python/utils/
cp ./clif/python/utils/proto_util.init.cc ${SRC_DIR}/clif/python/utils/
