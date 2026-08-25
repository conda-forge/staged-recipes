#!/usr/bin/env bash
# QEMU configure flag profiles
# Organizes feature flags by category for readability and reuse

# Get platform-specific configure flags
# Usage: get_platform_flags <platform>
# Bash 3.2 compat: `local -n` namerefs require bash 4.3+, which macOS stock
# /bin/bash does not have. Output is a global array (QEMU_PLATFORM_FLAGS)
# instead of a nameref out-parameter.
get_platform_flags() {
  local platform=$1

  QEMU_PLATFORM_FLAGS=()
  case "${platform}" in
    osx-*)
      # Disable apple-gfx (pvg) - requires macOS 12+ SDK
      QEMU_PLATFORM_FLAGS+=(--disable-pvg)
      ;;
  esac
}

# Build complete configure arguments based on build type
# Usage: build_configure_args <platform>
# Args:
#   platform: target_platform value
# Bash 3.2 compat: `local -n` namerefs require bash 4.3+, which macOS stock
# /bin/bash does not have. Output is a global array (QEMU_CONFIGURE_ARGS)
# instead of a nameref out-parameter.
build_configure_args() {
  local platform=$1

  # Base args for all builds
  QEMU_CONFIGURE_ARGS=(
    "--disable-docs"
  )

  if [[ -n "${CONDA_QEMU_TARGET_LIST:-}" ]]; then
    # Combined multi-target system emulator build (shared staging/cache build,
    # see rattler-build's staging/inherit pattern). CONDA_QEMU_TARGET_LIST is a
    # literal comma-joined --target-list value, e.g.
    # "aarch64-softmmu,ppc64-softmmu,riscv64-softmmu".
    QEMU_CONFIGURE_ARGS+=("--disable-linux-user" "--enable-system" "--target-list=${CONDA_QEMU_TARGET_LIST}")
    if [[ "${platform}" == win-* ]]; then
      # conda-forge has no win-64 dtc/libfdt package; aarch64-softmmu hard-requires
      # fdt, so build QEMU's vendored/subproject copy from source instead of
      # requiring a system library.
      QEMU_CONFIGURE_ARGS+=("--enable-fdt=internal")
    fi
  else
    echo "ERROR: CONDA_QEMU_TARGET_LIST is not set" >&2
    return 1
  fi

  # Add platform-specific flags. QEMU_PLATFORM_FLAGS can legitimately be
  # empty (non-osx platforms add none), and expanding an empty array under
  # `set -u` is an unbound-variable error on bash < 4.4, hence the guard.
  get_platform_flags "${platform}"
  QEMU_CONFIGURE_ARGS+=(${QEMU_PLATFORM_FLAGS[@]+"${QEMU_PLATFORM_FLAGS[@]}"})
}
