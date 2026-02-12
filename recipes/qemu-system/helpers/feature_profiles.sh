#!/usr/bin/env bash
# QEMU configure flag profiles
# Organizes feature flags by category for readability and reuse

# Get common package flags (for builds without emulators)
# These disable everything not needed for generating caches and installing firmware
# Returns array via nameref
get_common_package_flags() {
  local -n flags=$1

  flags=(
    # Block layer backends - not needed for data files
    "--disable-curl"
    "--disable-libssh"
    "--disable-bzip2"
    "--disable-lzo"
    "--disable-snappy"
    "--disable-zstd"
    "--disable-lzfse"

    # Display and input - not needed without emulators
    "--disable-sdl"
    "--disable-opengl"
    "--disable-virglrenderer"
    "--disable-vnc"
    "--disable-spice-protocol"
    "--disable-curses"

    # Audio backends (pa = pulseaudio)
    "--disable-alsa"
    "--disable-jack"
    "--disable-pipewire"
    "--disable-pa"
    "--disable-oss"

    # Hardware and device features
    "--disable-libusb"
    "--disable-usb-redir"
    "--disable-smartcard"
    "--disable-libudev"
    "--disable-libiscsi"
    "--disable-libnfs"
    "--disable-libpmem"
    "--disable-rbd"
    "--disable-glusterfs"

    # Security and crypto backends
    "--disable-gnutls"
    "--disable-gcrypt"
    "--disable-nettle"
    "--disable-seccomp"

    # Virtualization features
    "--disable-kvm"
    "--disable-hvf"
    "--disable-whpx"
    "--disable-numa"
    "--disable-linux-aio"
    "--disable-linux-io-uring"
    "--disable-slirp"
    "--disable-vde"

    # Miscellaneous
    "--disable-capstone"
    "--disable-fdt"
    "--disable-guest-agent"
    "--disable-tools"
  )
}

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
# Usage: build_configure_args <nameref_array> <target> <tools> <platform>
# Args:
#   nameref_array: Output array variable name
#   target: CONDA_QEMU_TARGET value (empty for common/tools)
#   tools: CONDA_QEMU_TOOLS value (empty for common package)
#   platform: target_platform value
build_configure_args() {
  local -n args=$1
  local target=$2
  local tools=$3
  local platform=$4

  # Base args for all builds
  args=(
    "--disable-linux-user"
    "--disable-docs"
    "--enable-strip"
  )

  if [[ -n "${target}" ]]; then
    # Architecture-specific build
    args+=("--enable-system" "--target-list=${target}-softmmu")
  else
    # Common/tools package: disable system emulators
    args+=("--disable-system")

    if [[ -n "${tools}" ]]; then
      # Tools package: enable guest agent
      args+=("--enable-guest-agent")
    else
      # Common package: minimize dependencies
      local common_flags
      get_common_package_flags common_flags
      args+=("${common_flags[@]}")
    fi
  fi

  # Add platform-specific flags
  local platform_flags
  get_platform_flags "${platform}" platform_flags
  args+=("${platform_flags[@]}")
}
