# =============================================================================
# qemu-user-patched: Build functions with variant support
# =============================================================================

# -----------------------------------------------------------------------------
# Patch application functions
# -----------------------------------------------------------------------------

_apply_variant_patches() {
  local qemu_src=$1
  local variant=$2

  pushd "${qemu_src}" || exit 1

  case "${variant}" in
    user)
      # No additional patches for base user variant
      # Base patches (Layer 0) are already applied via recipe source.patches
      echo "=== Variant 'user': No additional patches ==="
      ;;

    execve)
      # Apply execve interception patches (Layer 1)
      echo "=== Variant 'execve': Applying execve patches ==="
      for patch in "${RECIPE_DIR}/patches/execve/"*.patch; do
        if [[ -f "${patch}" ]]; then
          echo "Applying: $(basename "${patch}")"
          patch -p1 < "${patch}"
        fi
      done
      ;;

    zig)
      # Apply Zig PROT_WRITE patches (Layer 2)
      echo "=== Variant 'zig': Applying Zig patches ==="
      for patch in "${RECIPE_DIR}/patches/zig/"*.patch; do
        if [[ -f "${patch}" && ! "${patch}" == *.todo ]]; then
          echo "Applying: $(basename "${patch}")"
          patch -p1 < "${patch}"
        fi
      done
      # Note: 0006-elfload.c-PROT_WRITE.patch.todo is not a real patch yet
      if [[ ! -f "${RECIPE_DIR}/patches/zig/0006-elfload.c-PROT_WRITE.patch" ]]; then
        echo "WARNING: Zig PROT_WRITE patch not yet available - using base QEMU"
      fi
      ;;

    *)
      echo "ERROR: Unknown variant: ${variant}"
      exit 1
      ;;
  esac

  popd || exit 1
}

# -----------------------------------------------------------------------------
# Configure flags functions
# -----------------------------------------------------------------------------

_get_default_flags() {
  local -n flags=$1

  flags=(
    # No system emulation
    "--disable-system"
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

    # No vhost (system-emulation only)
    "--disable-vhost-user"
    "--disable-vhost-user-blk-server"
    "--disable-vhost-vdpa"
    "--disable-vhost-kernel"

    # No plugins (--dynamic-list linker flag unsupported by zig/lld)
    "--disable-plugins"
  )
}

_get_linux_user_flags() {
  local -n flags=$1

  flags+=(
    "--enable-linux-user"

    # Keep slirp for network syscall emulation (optional but useful)
    "--enable-slirp"

    # Debugging support
    "--enable-capstone"    # Disassembly for debugging
    # GDB stub is built-in for linux-user, no flag needed
  )
}

# -----------------------------------------------------------------------------
# Build and install function
# -----------------------------------------------------------------------------

_build_install_qemu() {
  local build_dir=$1
  local install_dir=$2
  local variant=$3

  local qemu_arch="${CONDA_QEMU_TARGET:-aarch64}"

  # Determine binary name based on variant
  local binary_name
  case "${variant}" in
    user)
      binary_name="qemu-${qemu_arch}"
      ;;
    execve)
      binary_name="qemu-execve-${qemu_arch}"
      ;;
    zig)
      binary_name="qemu-zig-${qemu_arch}"
      ;;
    *)
      echo "ERROR: Unknown variant: ${variant}"
      exit 1
      ;;
  esac

  # Get build flags
  local build_flags=()
  _get_default_flags build_flags
  _get_linux_user_flags build_flags
  build_flags+=("--target-list=${qemu_arch}-linux-user")

  # Create build directory
  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1

  # Configure
  # glibc 2.17 compat: add missing kernel constants as global defines
  _glibc_compat="-DMAP_FIXED_NOREPLACE=0x100000 -DMAP_SHARED_VALIDATE=0x03 -DMADV_WIPEONFORK=18 -DMADV_KEEPONFORK=19 -DNETLINK_SMC=22 -DSOL_ALG=279"

  # Meson unconditionally passes 'csrDT' to ar on Linux (T = thin archives).
  # zig-cc's linker frontend cannot parse thin archives, even ones created by
  # zig ar (llvm-ar). Wrap ar to strip the T modifier.
  local _real_ar="${AR}"
  mkdir -p "${build_dir}/_wrappers"
  cat > "${build_dir}/_wrappers/ar" <<WRAPPER
#!/usr/bin/env bash
# Strip T (thin-archive) from ar operation string (first arg, e.g. csrDT -> csrD)
args=("\${1/T/}" "\${@:2}")
exec ${_real_ar} "\${args[@]}"
WRAPPER
  chmod +x "${build_dir}/_wrappers/ar"
  export AR="${build_dir}/_wrappers/ar"

  ${SRC_DIR}/qemu_source/configure \
    --prefix="${install_dir}" \
    --extra-cflags="${_glibc_compat} -UNDEBUG" \
    "${build_flags[@]}"

  # Build
  ninja -j"${CPU_COUNT}"
  ninja install

  echo "=== Installed: ${install_dir}/bin/${binary_name} ==="

  # qemu-zig: relocate to lib/zig-qemu/ and create symlinks for zig's -fqemu
  if [[ "${variant}" == "zig" ]]; then
    local zig_qemu_dir="${PREFIX}/lib/zig-qemu"
    mkdir -p "${zig_qemu_dir}"
    mv "${install_dir}/bin/${binary_name}" "${zig_qemu_dir}/"
    # Symlink qemu-{arch} -> qemu-zig-{arch} so zig's -fqemu finds it via PATH
    ln -sf "${binary_name}" "${zig_qemu_dir}/qemu-${qemu_arch}"
    echo "  ${zig_qemu_dir}/${binary_name} (binary)"
    echo "  ${zig_qemu_dir}/qemu-${qemu_arch} -> ${binary_name} (symlink for zig -fqemu)"
  fi

  popd || exit 1
}

# -----------------------------------------------------------------------------
# Desktop assets function (for shared resources, not currently used)
# -----------------------------------------------------------------------------

_install_qemu_desktop_assets() {
  local qemu_src=$1
  local install_prefix=$2

  # Create icon directories
  mkdir -p "${install_prefix}"/share/{applications,icons}
  mkdir -p "${install_prefix}"/share/icons/hicolor/{16x16,24x24,32x32,48x48,64x64,128x128,256x256,512x512,scalable}/apps

  # Install desktop file (in ui/, not ui/icons/)
  install -Dm644 "${qemu_src}/ui/qemu.desktop" \
    "${install_prefix}/share/applications/qemu.desktop"

  # Install PNG icons (various sizes)
  for size in 16x16 24x24 32x32 48x48 64x64 128x128 256x256 512x512; do
    install -Dm644 "${qemu_src}/ui/icons/qemu_${size}.png" \
      "${install_prefix}/share/icons/hicolor/${size}/apps/qemu.png"
  done

  # Install BMP icon (32x32 only)
  install -Dm644 "${qemu_src}/ui/icons/qemu_32x32.bmp" \
    "${install_prefix}/share/icons/hicolor/32x32/apps/qemu.bmp"

  # Install SVG icon (scalable)
  install -Dm644 "${qemu_src}/ui/icons/qemu.svg" \
    "${install_prefix}/share/icons/hicolor/scalable/apps/qemu.svg"
}
