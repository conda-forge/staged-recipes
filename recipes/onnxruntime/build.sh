#!/bin/bash

set -exuo pipefail

rm -r cmake/external/onnx cmake/external/eigen
mv onnx eigen cmake/external/

pushd cmake/external/SafeInt/safeint
ln -s $PREFIX/include/SafeInt.hpp
popd

pushd cmake/external/json
ln -s $PREFIX/include single_include
popd

# Needs eigen 3.4
# rm -rf cmake/external/eigen
# pushd cmake/external
# ln -s $PREFIX/include/eigen3 eigen
# popd

python tools/ci_build/build.py \
    --enable_lto \
    --build_dir build-ci \
    --use_full_protobuf \
    --cmake_extra_defines "Protobuf_USE_STATIC_LIBS=OFF" Protobuf_PROTOC_EXECUTABLE=$PREFIX/bin/protoc Protobuf_INCLUDE_DIR=$PREFIX/include "onnxruntime_PREFER_SYSTEM_LIB=ON" onnxruntime_USE_COREML=OFF CMAKE_PREFIX_PATH=$PREFIX CMAKE_INSTALL_PREFIX=$PREFIX \
    --cmake_generator Ninja \
    --build_wheel \
    --config Release \
    --update \
    --build \
    --skip_submodule_sync

cp build-ci/Release/dist/onnxruntime-*.whl onnxruntime-${PKG_VERSION}-py3-none-any.whl
pip install onnxruntime-${PKG_VERSION}-py3-none-any.whl
