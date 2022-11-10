# !/usr/bin/env bash

set +ex

if [[ "${target_platform}" != "${build_platform}" ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
fi

export PKG_CONFIG_LIBDIR=$PREFIX/lib:$BUILD_PREFIX/lib
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig:$BUILD_PREFIX/lib/pkgconfig

mkdir -p openvino-build

cmake ${CMAKE_ARGS}                                                          \
    -DCMAKE_BUILD_TYPE=Release                                               \
    -DOPENVINO_EXTRA_MODULES=$SRC_DIR/openvino_contrib/modules/arm_plugin    \
    -DENABLE_INTEL_GNA=OFF                                                   \
    -DENABLE_INTEL_MYRIAD_COMMON=OFF                                         \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache                                     \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache                                       \
    -DENABLE_SYSTEM_TBB=ON                                                   \
    -DENABLE_SYSTEM_PUGIXML=ON                                               \
    -DENABLE_SYSTEM_PROTOBUF=OFF                                             \
    -DENABLE_COMPILE_TOOL=OFF                                                \
    -DENABLE_PYTHON=OFF                                                      \
    -DENABLE_CPPLINT=OFF                                                     \
    -DENABLE_CLANG_FORMAT=OFF                                                \
    -DENABLE_NCC_STYLE=OFF                                                   \
    -DENABLE_TEMPLATE=OFF                                                    \
    -DENABLE_REQUIREMENTS_INSTALL=OFF                                        \
    -DENABLE_SAMPLES=OFF                                                     \
    -DENABLE_DATA=OFF                                                        \
    -DBUILD_nvidia_plugin=OFF                                                \
    -DBUILD_java_api=OFF                                                     \
    -DCPACK_GENERATOR=CONDA-FORGE                                            \
    -DENABLE_WHEEL=OFF                                                       \
    -G Ninja                                                                 \
    -S openvino_sources                                                      \
    -B openvino-build

cmake --build openvino-build --config Release --parallel $CPU_COUNT --verbose
