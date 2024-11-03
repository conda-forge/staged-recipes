#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/_build_qemu.sh"

# --- Main ---

if [[ "${build_platform:-"win-64"}" == "win-64" ]] && [[ "${target_platform:-"win-64"}" == "win-64" ]]; then
  qemu_arch="aarch64"
  build_win_qemu \
    "${SRC_DIR}/_conda_build_${qemu_arch//-/_/}" \
    "${SRC_DIR}/_conda_install_${qemu_arch//-/_/}"

# Build aarch64 on linux and windows with gcc
elif [[ "${build_platform}" == "linux-64" ]] && [[ "${target_platform}" == "linux-64" ]]; then
  qemu_arch="aarch64"
  build_linux_qemu \
    ${qemu_arch} \
    "${qemu_arch}-conda-linux-gnu-" \
    "${BUILD_PREFIX}/${qemu_arch}-conda-linux-gnu/sysroot" \
    "${SRC_DIR}/_conda-build-${qemu_arch}" \
    "${SRC_DIR}/_conda-install-${qemu_arch}"

  qemu_arch="ppc64le"
  sysroot_arch="powerpc64le"
  build_linux_qemu \
    ${qemu_arch} \
    "${sysroot_arch}-conda-linux-gnu-" \
    "${BUILD_PREFIX}/${sysroot_arch}-conda-linux-gnu/sysroot" \
    "${SRC_DIR}/_conda-build-${qemu_arch}" \
    "${SRC_DIR}/_conda-install-${qemu_arch}"

#   qemu_arch="riscv64"
#   sysroot_arch="riscv64"
#   build_qemu \
#     ${qemu_arch} \
#     "${sysroot_arch}-conda-linux-gnu-" \
#     "${BUILD_PREFIX}/${sysroot_arch}-conda-linux-gnu/sysroot" \
#     "${SRC_DIR}/_conda-build-${qemu_arch}" \
#     "${SRC_DIR}/_conda-install-${qemu_arch}"

elif [[ "${build_platform}" == "osx-64" ]] && [[ "${target_platform}" == "osx-64" ]]; then
  qemu_arch="aarch64"
  build_osx_qemu \
    ${qemu_arch} \
    "${SRC_DIR}/_conda-build-${qemu_arch}" \
    "${SRC_DIR}/_conda-install-${qemu_arch}"

  # Changer RPATH to $PREFIX for qemu-img and qemu-system-aarch64 (for zstd)
  install_name_tool -add_rpath "${PREFIX}/lib" "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-img || true
  install_name_tool -add_rpath "${PREFIX}/lib" "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-system-aarch64 || true
  install_name_tool -add_rpath "${SRC_DIR}/_conda-install-${qemu_arch}"/lib "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-system-aarch64 || true

  # Prepare overlay
  mkdir -p ovl/etc/runlevels/default
  touch ovl/etc/.default_boot_services
  ln -sf /etc/init.d/local ovl/etc/runlevels/default
  cat > ovl/etc/local.d/auto-setup-alpine.start <<EOF
#! /bin/sh

set -o errexit
set -o nounset

# Uncomment to shutdown on completion.
#trap 'poweroff' EXIT INT

# Close standard input.
exec 0<&-

# Run only once.
rm -f /etc/local.d/auto-setup-alpine.start
rm -f /etc/runlevels/default/local

timeout 300 setup-alpine -ef /etc/auto-setup-alpine/answers
rm -rf /etc/auto-setup-alpine

# Disable password authentication
sed -i -e 's/^root:x:/root:*:/' -e 's/^conda_build:x:/conda_build:*:/' /etc/passwd
sed -i -e 's/^root:[^:]*/root:*/' -e 's/^conda_build:[^:]*/conda_build:*/' /etc/shadow

apk update
apk upgrade
EOF
  cat >/etc/doas.d/site.conf <<EOF
permit nopass :wheel
permit nopass keepenv root
EOF
  chmod 755 ovl/etc/local.d/auto-setup-alpine.start

  cat > ovl/etc/auto-setup-alpine/answers <<EOF
KEYMAPOPTS=none
HOSTNAMEOPTS=alpine
DEVDOPTS=mdev
TIMEZONEOPTS="-z UTC"
PROXYOPTS=none
APKREPOSOPTS="-1"
SSHDOPTS=openssh
NTPOPTS="openntpd"

# Diskless
DISKOPTS=none
LBUOPTS=none
APKCACHEOPTS=none

# Admin user name and ssh key.
USEROPTS="-a -u -g audio,video,netdev conda_build"
USERSSHKEY="ssh-rsa AAA... conda_build@localhost"

# Contents of /etc/network/interfaces
INTERFACESOPTS="auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
"
EOF
  tar --owner=0 --group=0 -czf localhost.apkovl.tar.gz -C ovl .
  # Create empty image
  "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-img create \
     -f qcow2 \
     -o compression_type=zlib \
     "${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/alpine-conda-vm.qcow2" \
     10G

  # Initialize qemu image
  python "${RECIPE_DIR}/helpers/qemu-user-aarch64.py" \
    --qemu-system "${SRC_DIR}/_conda-install-${qemu_arch}/bin/qemu-system-aarch64" \
    --cdrom ${SRC_DIR}/alpine-virt-${ALPINE_ISO_VERSION}-aarch64.iso \
    --drive ${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/alpine-conda-vm.qcow2 \
    --setup

  # Test qemu image
  python "${RECIPE_DIR}/helpers/qemu-user-aarch64.py" \
    --qemu-system "${SRC_DIR}/_conda-install-${qemu_arch}/bin/qemu-system-aarch64" \
    --drive ${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/alpine-conda-vm.qcow2 \
    --run "conda --version"


  # sleep 60
  # python "${RECIPE_DIR}/helpers/qmp-vm-build.py"

  # Safety kill qemu if we have not been able to shutdown cleanly
  sleep 120
  kill $(cat qemu_pid.txt) || true
fi
