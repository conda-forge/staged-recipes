#!/usr/bin/env bash
# =============================================================================
# qemu-user-patched: Unified build script with variant support
# =============================================================================
# Environment variables:
#   CONDA_QEMU_TARGET:  Target architecture (aarch64, ppc64le, s390x, riscv64)
#   CONDA_QEMU_VARIANT: Package variant (user, execve, zig)
# =============================================================================

set -euxo pipefail
IFS=$'\n\t'

if [[ ${BASH_VERSINFO[0]} -lt 5 || (${BASH_VERSINFO[0]} -eq 5 && ${BASH_VERSINFO[1]} -lt 2) ]]; then
  echo "re-exec with conda bash..."
  if [[ -x "${BUILD_PREFIX}/bin/bash" ]]; then
    exec "${BUILD_PREFIX}/bin/bash" "$0" "$@"
  else
    echo "ERROR: Could not find conda bash at ${BUILD_PREFIX}/bin/bash"
    exit 1
  fi
fi

source "${RECIPE_DIR}/functions.sh"

# --- Configuration ---

install_dir="${PREFIX}"
qemu_arch="${CONDA_QEMU_TARGET:-aarch64}"
qemu_variant="${CONDA_QEMU_VARIANT:-execve}"

echo "=== Building qemu-${qemu_variant}-${qemu_arch} ==="

# --- Step 1: Apply variant-specific patches ---

_apply_variant_patches "${SRC_DIR}/qemu_source" "${qemu_variant}"

# --- Step 2: Build and install QEMU ---

export host_os=linux
export CC="${ZIG_CC}"
export AR="${ZIG_AR}"
export RANLIB="${ZIG_RANLIB}"
_build_install_qemu "${SRC_DIR}/_conda-build-${qemu_variant}" "${install_dir}" "${qemu_variant}"

# --- Step 3: Install variant-specific files ---

case "${qemu_variant}" in
  zig)
    echo "=== qemu-zig-${qemu_arch}: No activation scripts ==="
    ;;

  *)
    echo "ERROR: Unknown variant: ${qemu_variant}"
    exit 1
    ;;
esac

echo "=== Build complete: qemu-${qemu_variant}-${qemu_arch} ==="
