#!/bin/bash
set -euxo pipefail

EXTRA_CMAKE_ARGS=()
if [[ "${target_platform}" == linux-* ]]; then
    # The OpenGL backend needs the EGL headers (from libegl-devel) and gl.xml
    # (from glad2). Dawn expects them in the layout of the Khronos registries.
    mkdir -p khronos/opengl khronos/egl
    ln -s "$("${BUILD_PREFIX}/bin/python" -c 'import glad, os; print(os.path.join(os.path.dirname(glad.__file__), "files"))')" khronos/opengl/xml
    ln -s "${PREFIX}/include" khronos/egl/api
    EXTRA_CMAKE_ARGS+=(
        -DDAWN_OPENGL_REGISTRY_DIR="${PWD}/khronos/opengl"
        -DDAWN_EGL_REGISTRY_DIR="${PWD}/khronos/egl"
    )
fi

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    ${EXTRA_CMAKE_ARGS[@]+"${EXTRA_CMAKE_ARGS[@]}"} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PROJECT_Dawn_INCLUDE="${RECIPE_DIR}/system_deps.cmake" \
    -DPython3_EXECUTABLE="${BUILD_PREFIX}/bin/python" \
    -DBUILD_SHARED_LIBS=OFF \
    -DDAWN_BUILD_MONOLITHIC_LIBRARY=SHARED \
    -DDAWN_ENABLE_INSTALL=ON \
    -DDAWN_FETCH_DEPENDENCIES=OFF \
    -DDAWN_BUILD_SAMPLES=OFF \
    -DDAWN_BUILD_TESTS=OFF \
    -DDAWN_BUILD_BENCHMARKS=OFF \
    -DDAWN_BUILD_PROTOBUF=OFF \
    -DDAWN_USE_GLFW=OFF \
    -DDAWN_WERROR=OFF \
    -DDAWN_JINJA2_DIR= \
    -DDAWN_MARKUPSAFE_DIR= \
    -DTINT_BUILD_CMD_TOOLS=OFF \
    -DTINT_BUILD_TESTS=OFF \
    -DTINT_BUILD_BENCHMARKS=OFF \
    -DTINT_BUILD_IR_BINARY=OFF

cmake --build build --parallel ${CPU_COUNT}
cmake --install build
