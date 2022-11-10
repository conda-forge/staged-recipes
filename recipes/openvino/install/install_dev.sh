# !/usr/bin/env bash

cmake --install $SRC_DIR/openvino-build --component core_dev
cmake --install $SRC_DIR/openvino-build --component core_c_dev
