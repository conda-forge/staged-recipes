install_qemu_to_prefix() {
  local qemu_arch=${1:-aarch64}
  local install_dir=${3:-"${PREFIX}"}

  pushd "${build_dir}" || exit 1
      make install > "${SRC_DIR}"/_install-"${qemu_arch}"-qemu.log 2>&1

      # Rename qemu-${qemu_arch} to qemu-execve-${qemu_arch}
      mv "${install_dir}"/bin/qemu-"${qemu_arch}" "${install_dir}"/bin/qemu-execve-"${qemu_arch}"
  popd || exit 1
}