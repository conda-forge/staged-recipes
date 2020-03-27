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

ls -l ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/usr/lib/jvm/
pushd ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.221-2.6.18.1.el7.aarch64/jre-abrt
  rm -rf lib
  ln -s ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.221-2.6.18.1.el7.aarch64/jre/lib lib
popd

pushd ${PREFIX}/aarch64-conda_cos7-linux-gnu/sysroot/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.221-2.6.18.1.el7.aarch64/jre/lib/security
  mkdir -p ../../../../../../../etc/pki/java/cacerts
popd

