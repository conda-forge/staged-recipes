#!/usr/bin/env bash

cmake --install $SRC_DIR/build --component core
cmake --install $SRC_DIR/build --component core_c
cmake --install $SRC_DIR/build --component tensorflow
cmake --install $SRC_DIR/build --component onnx
cmake --install $SRC_DIR/build --component ir
cmake --install $SRC_DIR/build --component paddle
