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

_build_install_qemu "${SRC_DIR}/_conda-build-${qemu_variant}" "${install_dir}" "${qemu_variant}"

# --- Step 3: Install variant-specific files ---

case "${qemu_variant}" in
  user)
    # No activation scripts for base user variant
    echo "=== qemu-user-${qemu_arch}: No activation scripts ==="
    ;;

  execve)
    # Install activation scripts for execve variant
    for SCRIPT in "activate" "deactivate"
    do
      mkdir -p "${install_dir}/etc/conda/${SCRIPT}.d"
      _qemu_arch="${qemu_arch}"
      [[ "${qemu_arch}" == "ppc64le" ]] && _qemu_arch="powerpc64le"
      sed -e "s|@QEMU_ARCH@|${_qemu_arch}|g" \
          "${RECIPE_DIR}/scripts/${SCRIPT}.sh" \
          > "${install_dir}/etc/conda/${SCRIPT}.d/qemu-execve-${qemu_arch}-${SCRIPT}.sh"
      chmod +x "${install_dir}/etc/conda/${SCRIPT}.d/qemu-execve-${qemu_arch}-${SCRIPT}.sh"
    done
    echo "=== qemu-execve-${qemu_arch}: Activation scripts installed ==="
    ;;

  zig)
    # No activation scripts for zig variant
    echo "=== qemu-zig-${qemu_arch}: No activation scripts ==="
    ;;

  *)
    echo "ERROR: Unknown variant: ${qemu_variant}"
    exit 1
    ;;
esac

echo "=== Build complete: qemu-${qemu_variant}-${qemu_arch} ==="
