# !/usr/bin/env bash

cmake --install "$SRC_DIR/openvino-build" --component core_dev
# remove requirements files since we shipped only c/cpp part
rm -rf $PREFIX/share/openvino