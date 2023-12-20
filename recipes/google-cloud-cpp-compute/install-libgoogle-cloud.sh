#!/bin/bash

set -euo pipefail

case "${PKG_NAME}" in
  libgoogle-cloud-*-devel)
    feature=${PKG_NAME/#libgoogle-cloud-/}
    feature=${feature/%-devel/}
    cmake --install .build/${feature} --component google_cloud_cpp_development
    ;;
  libgoogle-cloud-*)
    feature=${PKG_NAME/#libgoogle-cloud-/}
    cmake --install .build/${feature} --component google_cloud_cpp_runtime
    ;;
  *)
    echo Unknown package name "${PKG_NAME}"
    exit 1
    ;;
esac
