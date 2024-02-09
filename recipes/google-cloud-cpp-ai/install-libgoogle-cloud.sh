#!/bin/bash

set -euo pipefail

case "${PKG_NAME}" in
  libgoogle-cloud-*-devel)
    # Use shell expansion to temove any `libgoogle-cloud-` prefix and the
    # `-devel` suffix from PKG_NAME and find the feature name.
    #     https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
    feature=${PKG_NAME/#libgoogle-cloud-/}
    feature=${feature/%-devel/}
    cmake --install build/${feature} --component google_cloud_cpp_development
    ;;
  libgoogle-cloud-*)
    # As above, use shell expansion to find the feature name.
    feature=${PKG_NAME/#libgoogle-cloud-/}
    cmake --install build/${feature} --component google_cloud_cpp_runtime
    ;;
  *)
    echo Unknown package name "${PKG_NAME}"
    exit 1
    ;;
esac
