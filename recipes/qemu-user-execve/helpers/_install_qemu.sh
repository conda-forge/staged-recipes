install_qemu_arch() {
  local qemu_arch=${1:-aarch64}

  mkdir -p "${PREFIX}"/bin
  install -m 0755 "${SRC_DIR}/_conda-install-${qemu_arch}/bin/qemu-${qemu_arch}" "${PREFIX}/bin/${PKG_NAME}"

  # Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
  # This will allow them to be run on environment activation.
  for SCRIPT in "activate" "deactivate"
  do
    mkdir -p "${PREFIX}/etc/conda/${SCRIPT}.d"
    install -m 0755 "${RECIPE_DIR}/scripts/${SCRIPT}-${qemu_arch}.sh" "${PREFIX}/etc/conda/${SCRIPT}.d/${PKG_NAME}-${SCRIPT}.sh"
  done
}