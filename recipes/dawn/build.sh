#!/bin/bash
set -euxo pipefail

EXTRA_CMAKE_ARGS=()
if [[ "${target_platform}" == linux-* ]]; then
    # gl.xml is a separate source (see recipe.yaml); make sure it is the
    # revision this Dawn release pins.
    pinned=$(sed -n "s|.*/KhronosGroup/OpenGL-Registry@\([0-9a-f]*\)'.*|\1|p" DEPS)
    if [[ "${pinned}" != "${OPENGL_REGISTRY_COMMIT}" ]]; then
        echo "Dawn's DEPS pins OpenGL-Registry@${pinned:-<not found>}, but the recipe" \
             "downloads gl.xml from ${OPENGL_REGISTRY_COMMIT}. Update" \
             "opengl_registry_commit and the gl.xml sha256 in recipe.yaml." >&2
        exit 1
    fi

    # The OpenGL backend needs KHR/khrplatform.h; use the one from libegl-devel,
    # which also provides the EGL headers.
    EXTRA_CMAKE_ARGS+=(
        -DDAWN_KHRONOS_PLATFORM_INCLUDE_DIR="${PREFIX}/include"
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
