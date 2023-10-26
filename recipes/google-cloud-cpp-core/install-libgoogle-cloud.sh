#!/bin/bash

set -euo pipefail

case "${PKG_NAME}" in
  libgoogle-cloud-devel)
    cmake --install build_common --component google_cloud_cpp_development
    ;;
  libgoogle-cloud)
    cmake --install build_common --component google_cloud_cpp_runtime
    ;;
  libgoogle-cloud-iam-devel)
    ;;
  libgoogle-cloud-iam)
    ;;
  libgoogle-cloud-policytroubleshooter-devel)
    ;;
  libgoogle-cloud-policytroubleshooter)
    ;;
  libgoogle-cloud-*-devel)
    feature=${PKG_NAME/#libgoogle-cloud-/}
    feature=${feature/%-devel/}
    cmake --install build_${feature} --component google_cloud_cpp_development
    ;;
  libgoogle-cloud-*)
    feature=${PKG_NAME/#libgoogle-cloud-/}
    cmake --install build_${feature} --component google_cloud_cpp_runtime
    ;;
esac
