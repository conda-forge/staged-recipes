#!/usr/bin/env bash
set -exuo pipefail

# Builds libnpu_driver_compiler.so (the Compiler-in-Driver) from npu_compiler,
# consuming the conda-forge OpenVINO runtime + the libopenvino-npu-compiler-support
# shared lib rather than rebuilding OpenVINO. The Intel LLVM/MLIR fork
# (npu_compiler/thirdparty/llvm-project) is built in-tree and statically fused
# into the resulting shared lib.

cd "$SRC_DIR/npu_compiler"

# patch 0011 adds the -DNPU_CONDA_OUT_OF_TREE guard to npu_compiler's
# CMakeLists.txt (selecting cmake/conda_dev_shim.cmake instead of
# find_package(OpenVINODeveloperPackage)). The shim itself is shipped from the
# recipe into the source's cmake/ dir so the patched include() resolves at
# configure time.
cp "$RECIPE_DIR/cmake/conda_dev_shim.cmake" cmake/

mkdir -p build && pushd build

# Use the feedstock-pinned gcc 14 (gcc 15 fails OpenVINO/Xbyak compute_hash.cpp
# with -Wtemplate-body; the support lib + this compiler must share a toolchain).
export CCACHE_DIR="${CCACHE_DIR:-$PWD/../.ccache}"

# Configure validated 2026-05-25 via spike at ~/git/npu-cc-spike (env npucc):
#   - conda_dev_shim.cmake replaces find_package(OpenVINODeveloperPackage)
#   - ENABLE_TESTS=OFF (patch 0008: skips driver-compiler test/ dir)
#   - WIN32-only vs_version.rc.in guarded (patch 0009)
#   - add_tool_target post-ov_add_target guard (patch 0010)
#   - openvino::runtime::dev + openvino::itt shim targets in shim (v6 support lib)
#   - LLVM/MLIR configure passes cleanly; LibXml2/OCaml/BLAS are LLVM optional deps

cmake ${CMAKE_ARGS} \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DNPU_CONDA_OUT_OF_TREE=ON \
    -DBUILD_COMPILER_FOR_DRIVER=ON \
    -DENABLE_PREBUILT_LLVM_MLIR_LIBS=OFF \
    -DENABLE_TESTS=OFF \
    -DLLVM_USE_LINKER=lld \
    -DLLVM_PARALLEL_LINK_JOBS=2 \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DOpenVINO_DIR="$PREFIX/lib/cmake/openvino${PKG_VERSION}" \
    -DOpenVINONPUCompilerSupport_DIR="$PREFIX/lib/cmake/OpenVINONPUCompilerSupport" \
    ..

cmake --build . --parallel "${CPU_COUNT}"

# Install only the driver compiler shared lib.
install -d "$PREFIX/lib"
install -m 0755 "$(find . -name 'libnpu_driver_compiler.so' | head -1)" "$PREFIX/lib/"

popd
