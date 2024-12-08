#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/_build_install_qemu.sh"

# --- Main ---

install_dir="${CONDA_QEMU_INSTALL_DIR:-\"_conda_install\"}"
qemu_archs="${CONDA_QEMU_USER_ARCHS:-\"aarch64 ppc64le\"}"

# Compose the targets list
target_list="--target-list="
for qemu_arch in ${qemu_archs}
do
  if [ "${target_list}" != "--target-list=" ]; then
    target_list="${target_list},"
  fi
  target_list="${target_list}${qemu_arch}-linux-user"
done

# Build and install QEMU into the install directory
qemu_args=(${target_list})
_build_install_qemu "${SRC_DIR}/_conda-build" "${SRC_DIR}/${install_dir}" "${qemu_args[@]}"

# Copy the [de]activate scripts to $<install dir>/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for SCRIPT in "activate" "deactivate"
do
  mkdir -p "${SRC_DIR}/${install_dir}/etc/conda/${SCRIPT}.d"
  for qemu_arch in ${qemu_archs}
  do
    install -m 0755 "${RECIPE_DIR}/scripts/${SCRIPT}-${qemu_arch}.sh" "${SRC_DIR}/${install_dir}/etc/conda/${SCRIPT}.d/qemu-execve-${qemu_arch}-${SCRIPT}.sh"
  done
done

# Rename execs
for qemu_arch in ${qemu_archs}
do
  mv "${SRC_DIR}/${install_dir}"/bin/qemu-${qemu_arch} "${SRC_DIR}/${install_dir}"/bin/qemu-execve-${qemu_arch}
done

# Only files installed in prefix will remain in the build cache
tar -cf - -C "${SRC_DIR}" "${install_dir}" | tar -xf - -C "${PREFIX}"
