#!/bin/bash
set -euxo pipefail

export ROCM_PATH="${PREFIX}"

# Avoid creating bytecode caches inside the host prefix while Tensile imports
# its build-time Python dependencies. Rattler otherwise sees them as unowned
# staging files.
export PYTHONDONTWRITEBYTECODE=1

# Expand xnack variants for gfx908 if present in CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS.
# See https://github.com/ROCm/ROCm/issues/2358
GPU_TARGETS_EXPANDED=""
if [[ -n "${CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS:-}" ]]; then
    IFS=';' read -r -a _rocm_targets <<< "${CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS}"
    _expanded_targets=()
    for _t in "${_rocm_targets[@]}"; do
        case "${_t}" in
            gfx908)
                _expanded_targets+=("gfx908:xnack+" "gfx908:xnack-")
                ;;
            "")
                ;;
            *)
                _expanded_targets+=("${_t}")
                ;;
        esac
    done
    GPU_TARGETS_EXPANDED=$(IFS=';'; echo "${_expanded_targets[*]}")
fi

echo "Original CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS: ${CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS:-}"
echo "GPU_TARGETS option passed after rocblas adjustments: ${GPU_TARGETS_EXPANDED}"

# Parts of Tensile hardcode amdclang/amdclang++ by filename; see ROCm/rocm-libraries#944.
ln -sf -- "${HIPCXX}" "${BUILD_PREFIX}/bin/amdclang++"
ln -sf -- "${HIPCXX}" "${BUILD_PREFIX}/bin/amdclang"

# Disable ROCTX explicitly (roctracer is not yet packaged in conda-forge) so CMake
# cannot silently pick up a system installation under /opt/rocm.
# CMAKE_ARGS contains separate command-line options.
# shellcheck disable=SC2086
cmake -GNinja ${CMAKE_ARGS} \
    -DCMAKE_C_COMPILER="${BUILD_PREFIX}/bin/amdclang" \
    -DCMAKE_CXX_COMPILER="${BUILD_PREFIX}/bin/amdclang++" \
    -DGPU_TARGETS="${GPU_TARGETS_EXPANDED}" \
    -DAMDGPU_TARGETS="${GPU_TARGETS_EXPANDED}" \
    -DTENSILE_USE_OPENMP=ON \
    -Dhipblaslt_path="${PREFIX}" \
    -DROCTRACER_INCLUDE_DIR=OFF \
    -DROCTX_LIBRARY=OFF \
    -Bbuild -S projects/rocblas
cmake --build ./build --parallel "${CPU_COUNT}"
cmake --install ./build

rm -f -- "${BUILD_PREFIX}/bin/amdclang++"
rm -f -- "${BUILD_PREFIX}/bin/amdclang"
