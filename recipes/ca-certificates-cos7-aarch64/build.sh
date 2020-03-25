#!/bin/bash

set -o errexit -o pipefail

mkdir -p "${PREFIX}"/aarch64-conda_cos7-linux-gnu/sysroot
if [[ -d usr/lib ]]; then
  if [[ ! -d lib ]]; then
    ln -s usr/lib lib
  fi
fi
if [[ -d usr/lib64 ]]; then
  if [[ ! -d lib64 ]]; then
    ln -s usr/lib64 lib64
  fi
fi
pushd "${PREFIX}"/aarch64-conda_cos7-linux-gnu/sysroot > /dev/null 2>&1
cp -Rf "${SRC_DIR}"/binary/* .

pushd ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/etc/pki/java
  rm -f cacerts
  mkdir -p ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/java/cacerts
  ln -s ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/java/cacerts cacerts
popd

pushd ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/etc/pki/tls
  rm -f cert.pem
  echo "PLACEHOLDER"> ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
  ln -s ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem cert.pem
popd

pushd ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/etc/pki/tls/certs
  rm -f ca-bundle.crt
  ln -s ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem ca-bundle.crt
popd

pushd ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/etc/pki/tls/certs
  rm ca-bundle.trust.crt
  echo "PLACEHOLDER"> ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
  ln -s ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt ca-bundle.trust.crt
popd
