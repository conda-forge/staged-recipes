#!/bin/bash

set -euo pipefail

case "${PKG_NAME}" in
  libgoogle-cloud-bigquery-devel)
    cmake --install build --component google_cloud_cpp_development
    ;;
  libgoogle-cloud-bigquery)
    cmake --install build --component google_cloud_cpp_runtime
    ;;
  *)
    echo Unknown package name "${PKG_NAME}"
    exit 1
    ;;
esac
