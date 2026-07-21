#!/usr/bin/env bash
set -exuo pipefail

# Vendored / static "Compiler-in-Driver" (CiD) build -- the upstream-recommended
# way to produce the NPU driver compiler libraries.
#
# Instead of consuming an experimental OpenVINO output, this recipe vendors the
# matching OpenVINO source (openvinotoolkit/openvino @ 2026.2.0) and builds it
# the way Intel documents the CiD: configure the OpenVINO source with
# BUILD_SHARED_LIBS=OFF and attach npu_compiler as an OPENVINO_EXTRA_MODULES,
# then build only the CiD compiler targets. OpenVINO core + the IR frontend +
# the Intel LLVM/MLIR fork + npu_plugin_elf + the NPU cost model are all
# statically fused into the compiler libraries. As of OpenVINO 2026.2 the CiD
# is two shared libs -- libopenvino_intel_npu_compiler_loader.so (the thin VCL
# loader the OpenVINO NPU plugin dlopens) and libopenvino_intel_npu_compiler.so
# (the MLIR/VPUX compiler the loader dlopens). The result has no run dependency
# on a shared libopenvino at all.
#
# Flags below mirror npu_compiler's own `cid-linux` CMake preset
# (CMakePresets.json) plus the conda-forge "use system libraries, never
# download" conventions (ENABLE_SYSTEM_*; ENABLE_SYSTEM_TBB=ON overrides the
# preset's bundled-oneTBB download, which is impossible in an offline build).

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
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5

# As of OpenVINO 2026.2 / npu_ud_2026_20, the Compiler-in-Driver is split into
# two shared libraries (BUILD_COMPILER_FOR_DRIVER): the thin VCL loader
# (libopenvino_intel_npu_compiler_loader.so), which the OpenVINO NPU plugin
# dlopens, and the heavy MLIR/VPUX compiler (libopenvino_intel_npu_compiler.so),
# which the loader in turn dlopens by base name at runtime. Neither ships in the
# conda-forge openvino packages (built with ENABLE_INTEL_NPU_INTERNAL=OFF), so
# build and install both.
cmake --build "$SRC_DIR/build" \
    --target openvino_intel_npu_compiler openvino_intel_npu_compiler_loader \
    --parallel "${CPU_COUNT}"

# Install both compiler shared libs. OpenVINO writes build artifacts to its own
# output tree ($SRC_DIR/openvino/bin/<arch>/Release), not the CMake binary dir,
# so search the whole source tree for each.
install -d "$PREFIX/lib"
for lib in libopenvino_intel_npu_compiler.so libopenvino_intel_npu_compiler_loader.so; do
    so_path="$(find "$SRC_DIR" -name "$lib" -type f -print -quit)"
    test -n "$so_path"  # fail loudly if a target did not produce its .so
    install -m 0755 "$so_path" "$PREFIX/lib/"
done
