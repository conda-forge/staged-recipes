#!/usr/bin/env bash
set -exuo pipefail

# The main source is extracted with `no_hoist: true` (see meta.yaml) so
# the original top-level directory is preserved as a subdir of $SRC_DIR.
cd "linux-npu-driver-${PKG_VERSION}"

# Keep the upstream build focused on the userspace driver:
#  * ENABLE_NPU_COMPILER_BUILD=OFF — the LLVM/MLIR-based driver compiler
#    is a much larger build and is shipped from a separate recipe.
#  * ENABLE_VALIDATION_BUILD=OFF / ENABLE_TOOLS_BUILD=OFF — no test apps.
#  * ENABLE_NPU_PERFETTO_BUILD=OFF — no Perfetto tracing (default).
#  * ENABLE_NPU_UNIT_TESTS=OFF — added by patch 0002, gates the
#    third_party/googletest-dependent umd unit_tests subdirs.
# Upstream's third_party/cmake/level-zero.cmake first tries pkg-config;
# the level-zero-devel host dep above provides level-zero.pc so the
# build does not need to fetch the kobuk PPA .debs or fall back to
# building Level Zero from source.
mkdir -p build
pushd build

cmake ${CMAKE_ARGS} \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DENABLE_NPU_COMPILER_BUILD=OFF \
    -DENABLE_NPU_PERFETTO_BUILD=OFF \
    -DENABLE_VALIDATION_BUILD=OFF \
    -DENABLE_TOOLS_BUILD=OFF \
    -DENABLE_NPU_UNIT_TESTS=OFF \
    -DENABLE_NPU_LOGGING=ON \
    ..

cmake --build . --parallel "${CPU_COUNT}"

# Install only the userspace driver component. This skips:
#   * fw-npu (kernel firmware — cannot live in $CONDA_PREFIX)
#   * driver-compiler-npu (packaged separately)
#   * validation-npu, tools (not built)
cmake --install . --component level-zero-npu --prefix "$PREFIX"

popd
