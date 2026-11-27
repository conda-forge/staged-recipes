#!/bin/bash
set -euxo pipefail

# hipblaslt internals default to /opt/rocm unless ROCM_PATH is set.
export ROCM_PATH="${PREFIX}"

# Avoid creating bytecode caches inside the host prefix while Tensile imports
# its build-time Python dependencies. Rattler otherwise sees them as unowned
# staging files.
export PYTHONDONTWRITEBYTECODE=1

# Expand xnack variants for gfx908 and gfx90a if present in CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS.
# Drop gfx1030, which hipBLASLt does not support in this build configuration.
GPU_TARGETS_EXPANDED=""
if [[ -n "${CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS:-}" ]]; then
    IFS=';' read -r -a _rocm_targets <<< "${CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS}"
    _expanded_targets=()
    for _t in "${_rocm_targets[@]}"; do
        case "${_t}" in
            gfx908)
                _expanded_targets+=("gfx908:xnack+" "gfx908:xnack-")
                ;;
            gfx90a)
                _expanded_targets+=("gfx90a:xnack+" "gfx90a:xnack-")
                ;;
            gfx908:*|gfx90a:*)
                _expanded_targets+=("${_t}")
                ;;
            gfx1030|gfx1030:*)
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
echo "GPU_TARGETS option passed after hipblaslt adjustments: ${GPU_TARGETS_EXPANDED}"

# Parts of Tensile hardcode amdclang/amdclang++ by filename; see ROCm/rocm-libraries#944.
ln -sf -- "${HIPCXX}" "${BUILD_PREFIX}/bin/amdclang++"
ln -sf -- "${HIPCXX}" "${BUILD_PREFIX}/bin/amdclang"

# CMAKE_ARGS contains separate command-line options.
# shellcheck disable=SC2086
cmake -GNinja ${CMAKE_ARGS} \
    -DCMAKE_C_COMPILER="${BUILD_PREFIX}/bin/amdclang" \
    -DCMAKE_CXX_COMPILER="${BUILD_PREFIX}/bin/amdclang++" \
    -DGPU_TARGETS="${GPU_TARGETS_EXPANDED}" \
    -DAMDGPU_TARGETS="${GPU_TARGETS_EXPANDED}" \
    -DPython_EXECUTABLE="${PYTHON}" \
    -DPython3_EXECUTABLE="${PYTHON}" \
    -DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS \
    -DHIPBLASLT_ENABLE_ROCROLLER=ON \
    -DHIPBLASLT_ENABLE_THEROCK=ON \
    -DHIPBLASLT_ENABLE_FETCH=OFF \
    -DHIPBLASLT_ENABLE_CLIENT=OFF \
    -DHIPBLASLT_BUILD_TESTING=OFF \
    -DHIPBLASLT_ENABLE_SAMPLES=OFF \
    -DHIPBLASLT_ENABLE_MARKER=OFF \
    -Bbuild -S projects/hipblaslt
cmake --build ./build --parallel "${CPU_COUNT}"
cmake --install ./build

rm -f -- "${BUILD_PREFIX}/bin/amdclang++"
rm -f -- "${BUILD_PREFIX}/bin/amdclang"
