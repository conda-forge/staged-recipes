#!/usr/bin/env bash
set -exuo pipefail

# Vendored / static "Compiler-in-Driver" (CiD) build -- the upstream-recommended
# way to produce libnpu_driver_compiler.so.
#
# Instead of consuming an experimental OpenVINO output, this recipe vendors the
# matching OpenVINO source (openvinotoolkit/openvino @ 2026.1.0) and builds it
# the way Intel documents the CiD: configure the OpenVINO source with
# BUILD_SHARED_LIBS=OFF and attach npu_compiler as an OPENVINO_EXTRA_MODULES,
# then build only the npu_driver_compiler target. OpenVINO core + the IR
# frontend + the Intel LLVM/MLIR fork + npu_plugin_elf + the NPU cost model are
# all statically fused into the single self-contained libnpu_driver_compiler.so.
# The result has no run dependency on a shared libopenvino at all.
#
# Flags below mirror npu_compiler's own `cid-linux` CMake preset
# (CMakePresets.json) plus the conda-forge "use system libraries, never
# download" conventions (ENABLE_SYSTEM_*; ENABLE_SYSTEM_TBB=ON overrides the
# preset's bundled-oneTBB download, which is impossible in an offline build).

# Persist ccache across local iterations (the LLVM/MLIR fork is the long pole).
export CCACHE_DIR="${CCACHE_DIR:-${SRC_DIR}/../.ccache}"
export CCACHE_MAXSIZE="${CCACHE_MAXSIZE:-25G}"

mkdir -p "$SRC_DIR/build"

cmake ${CMAKE_ARGS} \
    -G Ninja \
    -S "$SRC_DIR/openvino" \
    -B "$SRC_DIR/build" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DOPENVINO_EXTRA_MODULES="$SRC_DIR/npu_compiler" \
    -DBUILD_COMPILER_FOR_DRIVER=ON \
    `# --- cid-linux preset: trim everything but the NPU compiler path ---` \
    -DENABLE_LTO=OFF \
    -DENABLE_FASTER_BUILD=OFF \
    -DENABLE_CPPLINT=OFF \
    -DENABLE_TESTS=OFF \
    -DENABLE_FUNCTIONAL_TESTS=OFF \
    -DENABLE_SAMPLES=OFF \
    -DENABLE_JS=OFF \
    -DENABLE_PYTHON=OFF \
    -DENABLE_PYTHON_PACKAGING=OFF \
    -DENABLE_WHEEL=OFF \
    -DENABLE_OV_ONNX_FRONTEND=OFF \
    -DENABLE_OV_PADDLE_FRONTEND=OFF \
    -DENABLE_OV_PYTORCH_FRONTEND=OFF \
    -DENABLE_OV_TF_FRONTEND=OFF \
    -DENABLE_OV_TF_LITE_FRONTEND=OFF \
    -DENABLE_OV_JAX_FRONTEND=OFF \
    -DENABLE_OV_IR_FRONTEND=ON \
    -DENABLE_MULTI=OFF \
    -DENABLE_HETERO=OFF \
    -DENABLE_AUTO=OFF \
    -DENABLE_AUTO_BATCH=OFF \
    -DENABLE_TEMPLATE=OFF \
    -DENABLE_PROXY=OFF \
    -DENABLE_INTEL_CPU=OFF \
    -DENABLE_INTEL_GPU=OFF \
    -DENABLE_NPU_PLUGIN_ENGINE=OFF \
    -DENABLE_ZEROAPI_BACKEND=OFF \
    -DENABLE_DRIVER_COMPILER_ADAPTER=OFF \
    -DENABLE_INTEL_NPU_INTERNAL=OFF \
    -DENABLE_INTEL_NPU_PROTOPIPE=OFF \
    -DENABLE_PRIVATE_TESTS=OFF \
    -DENABLE_NPU_LSP_SERVER=OFF \
    `# --- threading + system libraries (conda-forge: no network) ---` \
    -DTHREADING=TBB \
    -DENABLE_TBBBIND_2_5=OFF \
    -DENABLE_TBB_RELEASE_ONLY=OFF \
    -DENABLE_SYSTEM_TBB=ON \
    -DENABLE_SYSTEM_PUGIXML=ON \
    -DENABLE_SYSTEM_LEVEL_ZERO=ON \
    -DENABLE_SYSTEM_FLATBUFFERS=ON \
    -DENABLE_PROFILING_ITT=OFF \
    -DENABLE_OPENCV=OFF \
    `# --- in-tree Intel LLVM/MLIR fork: link with lld, cap link parallelism ---` \
    -DENABLE_PREBUILT_LLVM_MLIR_LIBS=OFF \
    -DLLVM_USE_LINKER=lld \
    -DLLVM_PARALLEL_LINK_JOBS=2 \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5

cmake --build "$SRC_DIR/build" --target npu_driver_compiler --parallel "${CPU_COUNT}"

# Install only the self-contained driver compiler shared lib. OpenVINO writes
# build artifacts to its own output tree ($SRC_DIR/openvino/bin/<arch>/Release),
# not the CMake binary dir, so search the whole source tree for it.
driver_compiler_so="$(find "$SRC_DIR" -name 'libnpu_driver_compiler.so' -type f -print -quit)"
install -d "$PREFIX/lib"
install -m 0755 "$driver_compiler_so" "$PREFIX/lib/"
