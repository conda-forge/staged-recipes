#!/usr/bin/env bash

set -euxo pipefail

if [[ "${target_platform}" == "linux-"* ]]; then
  # Split off last part of the version string
  _pkg_version=$(echo "${PKG_VERSION}" | sed -e 's/\.[^\.]+$//')
  ./bootstrap-${_pkg_version} --prefix=$(pkg-config --variable=prefix mono)
  ./configure --prefix=$(pkg-config --variable=prefix mono)
  make
fi
