#!/bin/bash
set -euxo pipefail

mkdir -p ort-root/include/onnxruntime
cp "${PREFIX}"/include/onnxruntime/core/session/*.{h,inc} ort-root/include/onnxruntime/
export ONNXRUNTIME_ROOT_DIR="${SRC_DIR}/ort-root"
export INTEL_OPENVINO_DIR="${PREFIX}"

cmake -G Ninja -B build ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DOVEP_PLUGIN_BUILD_TESTS=OFF \
    -DOVEP_PLUGIN_BUILD_TOOLS=OFF \
    -DOVEP_PLUGIN_BUNDLE_RUNTIME=OFF \
    -DOVEP_PLUGIN_PRODUCTION_BUILD=ON \
    -DGIT_COMMIT_ID="v${PKG_VERSION}" \
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON
cmake --build build --target onnxruntime_providers_openvino_plugin --parallel "${CPU_COUNT}"

mkdir -p "${PREFIX}/lib"
cp -P build/plugin/libonnxruntime_providers_openvino_plugin.so* "${PREFIX}/lib/"
