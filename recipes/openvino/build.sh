# !/usr/bin/env bash

set +ex

if [[ "${target_platform}" != "${build_platform}" ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
fi

export PKG_CONFIG_LIBDIR=$PREFIX/lib:$BUILD_PREFIX/lib
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig:$BUILD_PREFIX/lib/pkgconfig

mkdir -p openvino-build

cmake ${CMAKE_ARGS}                      \
    -DCMAKE_BUILD_TYPE=Release           \
    -DENABLE_INTEL_CPU=ON                \
    -DENABLE_INTEL_GPU=ON                \
    -DENABLE_INTEL_GNA=ON                \
    -DENABLE_INTEL_MYRIAD=ON             \
    -DENABLE_OV_IR_FRONTEND=ON           \
    -DENABLE_OV_ONNX_FRONTEND=ON         \
    -DENABLE_OV_PADDLE_FRONTEND=ON       \
    -DENABLE_OV_TF_FRONTEND=ON           \
    -DENABLE_OPENCV=OFF                  \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache   \
    -DENABLE_SYSTEM_TBB=ON               \
    -DENABLE_SYSTEM_PUGIXML=ON           \
    -DENABLE_CPPLINT=OFF                 \
    -DENABLE_CLANG_FORMAT=OFF            \
    -DENABLE_IR_V7_READER=OFF            \
    -DENABLE_NCC_STYLE=OFF               \
    -DENABLE_TEMPLATE=OFF                \
    -DENABLE_REQUIREMENTS_INSTALL=OFF    \
    -DENABLE_SAMPLES=OFF                 \
    -DENABLE_TESTS=ON                    \
    -DENABLE_DATA=OFF                    \
    -DBUILD_nvidia_plugin=OFF            \
    -DBUILD_java_api=OFF                 \
    -DCPACK_GENERATOR=CONDA-FORGE        \
    -S openvino_sources \
    -B openvino-build

# TODO: add usage of OpenVINO Conrtib repo

cmake --build openvino-build --config Release --parallel $CPU_COUNT -- -k
