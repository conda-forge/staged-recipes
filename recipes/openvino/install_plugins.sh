# !/usr/bin/env bash

cmake --install $SRC_DIR/openvino-build --component cpu
cmake --install $SRC_DIR/openvino-build --component gpu
cmake --install $SRC_DIR/openvino-build --component auto
cmake --install $SRC_DIR/openvino-build --component hetero
cmake --install $SRC_DIR/openvino-build --component batch
