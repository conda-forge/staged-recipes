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

# Get linux-user specific flags (minimal deps, no devices)
# Returns array via nameref
get_linux_user_flags() {
  local -n flags=$1

  flags=(
    # No system emulation
    "--disable-system"
    "--enable-linux-user"
    "--disable-bsd-user"

    # No display needed
    "--disable-sdl"
    "--disable-gtk"
    "--disable-opengl"
    "--disable-vnc"
    "--disable-curses"
    "--disable-virglrenderer"
    "--disable-spice-protocol"

    # No device emulation
    "--disable-libusb"
    "--disable-usb-redir"
    "--disable-smartcard"
    "--disable-libudev"
    "--disable-libiscsi"
    "--disable-libnfs"
    "--disable-libpmem"
    "--disable-rbd"
    "--disable-glusterfs"
    "--disable-fdt"

    # No audio
    "--disable-alsa"
    "--disable-jack"
    "--disable-pipewire"
    "--disable-pa"
    "--disable-oss"

    # No block layer backends
    "--disable-curl"
    "--disable-libssh"
    "--disable-bzip2"
    "--disable-lzo"
    "--disable-snappy"
    "--disable-zstd"
    "--disable-lzfse"

    # No virtualization features (user-mode doesn't need them)
    "--disable-kvm"
    "--disable-hvf"
    "--disable-whpx"
    "--disable-numa"
    "--disable-linux-aio"
    "--disable-linux-io-uring"

    # Disable tools and guest agent
    "--disable-tools"
    "--disable-guest-agent"

    # Keep slirp for network syscall emulation (optional but useful)
    "--enable-slirp"

    # Debugging support
    "--enable-capstone"    # Disassembly for debugging
    # GDB stub is built-in for linux-user, no flag needed
  )
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
    "--enable-strip"
  )

  if [[ "${mode}" == "linux-user" ]]; then
    # Linux-user mode build
    local user_flags
    get_linux_user_flags user_flags
    args+=("${user_flags[@]}")
    args+=("--target-list=${target}-linux-user")
  elif [[ -n "${target}" ]]; then
    # System emulator build
    args+=("--disable-linux-user" "--enable-system" "--target-list=${target}-softmmu")
  else
    # Common/tools package: disable system emulators
    args+=("--disable-linux-user" "--disable-system")

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
