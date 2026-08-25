#!/usr/bin/env bash
# QEMU configure flag profiles
# Organizes feature flags by category for readability and reuse

# Get platform-specific configure flags
# Usage: get_platform_flags <platform> <nameref_array>
get_platform_flags() {
  local platform=$1
  local -n flags=$2

  flags=()
  case "${platform}" in
    osx-*)
      # Disable apple-gfx (pvg) - requires macOS 12+ SDK
      flags+=(--disable-pvg)
      ;;
  esac
}

# Build complete configure arguments based on build type
# Usage: build_configure_args <nameref_array> <target> <tools> <platform> [mode]
# Args:
#   nameref_array: Output array variable name
#   target: CONDA_QEMU_TARGET value (empty for common/tools)
#   tools: CONDA_QEMU_TOOLS value (empty for common package)
#   platform: target_platform value
#   mode: "system" (default) or "linux-user"
build_configure_args() {
  local -n args=$1
  local target=$2
  local tools=$3
  local platform=$4
  local mode=${5:-system}

  # Base args for all builds
  args=(
    "--disable-docs"
  )

  if [[ -n "${CONDA_QEMU_TARGET_LIST:-}" ]]; then
    # Combined multi-target system emulator build (shared staging/cache build,
    # see rattler-build's staging/inherit pattern). CONDA_QEMU_TARGET_LIST is a
    # literal comma-joined --target-list value, e.g.
    # "aarch64-softmmu,ppc64-softmmu,riscv64-softmmu".
    args+=("--disable-linux-user" "--enable-system" "--target-list=${CONDA_QEMU_TARGET_LIST}")
    if [[ "${platform}" == win-* ]]; then
      # conda-forge has no win-64 dtc/libfdt package; aarch64-softmmu hard-requires
      # fdt, so build QEMU's vendored/subproject copy from source instead of
      # requiring a system library.
      args+=("--enable-fdt=internal")
    fi
  else
    echo "ERROR: CONDA_QEMU_TARGET_LIST is not set" >&2
    return 1
  fi

  # Add platform-specific flags
  local platform_flags
  get_platform_flags "${platform}" platform_flags
  args+=("${platform_flags[@]}")
}
