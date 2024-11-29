#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "${PREFIX}"/bin
pushd "${SRC_DIR}/_conda_install/bin"
  for tool in $(ls qemu-system-*)
  do
    install -m 0755 "${tool}" "${PREFIX}/bin/${tool}"
  done
popd

mkdir -p "${PREFIX}"/libexec
pushd "${SRC_DIR}/_conda_install/libexec"
  for tool in $(ls qemu-bridge-helper)
  do
    install -m 0755 "${tool}" "${PREFIX}/libexec/${tool}"
  done
popd
