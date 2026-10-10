#!/bin/bash
set -ex

# The standard data libraries go under share/ rather than the upstream default
# of a top-level libraries/ directory in the prefix. Consumers locate them via
# MATERIALX_STDLIB_DIR, which MaterialXConfig.cmake sets from this path.
# LOCAL ONLY, do not commit: keep XQuartz's libGL and Homebrew out of the build host
[[ "${target_platform}" == osx-* ]] && CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_IGNORE_PREFIX_PATH=/opt/homebrew;/usr/local;/usr/X11R6;/usr/X11;/opt/X11"

cmake ${CMAKE_ARGS} -GNinja -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DMATERIALX_BUILD_SHARED_LIBS=ON \
    -DMATERIALX_BUILD_PYTHON=OFF \
    -DMATERIALX_BUILD_VIEWER=OFF \
    -DMATERIALX_BUILD_GRAPH_EDITOR=OFF \
    -DMATERIALX_BUILD_DOCS=OFF \
    -DMATERIALX_BUILD_OIIO=OFF \
    -DMATERIALX_BUILD_OCIO=OFF \
    -DMATERIALX_BUILD_TESTS=ON \
    -DMATERIALX_TEST_RENDER=OFF \
    -DMATERIALX_BUILD_USE_CCACHE=OFF \
    -DMATERIALX_BUILD_APPLE_FRAMEWORK=OFF \
    -DMATERIALX_INSTALL_RESOURCES=OFF \
    -DMATERIALX_INSTALL_STDLIB_PATH=share/materialx/libraries

cmake --build build --parallel ${CPU_COUNT}

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
    ctest --test-dir build --output-on-failure --parallel ${CPU_COUNT}
fi

cmake --install build

# Upstream installs its top-level docs into the prefix root.
rm -f "${PREFIX}"/{CHANGELOG.md,LICENSE,README.md,THIRD-PARTY.md}
