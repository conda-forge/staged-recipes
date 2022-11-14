# !/usr/bin/env bash

cmake --install "$SRC_DIR/openvino-build" --component core
cmake --install "$SRC_DIR/openvino-build" --component core_c
cmake --install "$SRC_DIR/openvino-build" --component tensorflow
cmake --install "$SRC_DIR/openvino-build" --component onnx
cmake --install "$SRC_DIR/openvino-build" --component ir
cmake --install "$SRC_DIR/openvino-build" --component paddle
