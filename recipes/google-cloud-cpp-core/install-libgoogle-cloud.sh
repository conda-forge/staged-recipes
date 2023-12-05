#!/bin/bash

set -euo pipefail

case "${PKG_NAME}" in
  libgoogle-cloud-devel)
    cmake --install .build/common --component google_cloud_cpp_development
    ;;
  libgoogle-cloud)
    cmake --install .build/common --component google_cloud_cpp_runtime
    ;;
  libgoogle-cloud-iam-devel)
    # Do nothing, this is installed by `libgoogle-cloud-pubsub-devel`.
    ;;
  libgoogle-cloud-iam)
    # Do nothing, this is installed by `libgoogle-cloud-pubsub`.
    ;;
  libgoogle-cloud-policytroubleshooter-devel)
    # Do nothing, this is installed by `libgoogle-cloud-pubsub-devel`.
    ;;
  libgoogle-cloud-policytroubleshooter)
    # Do nothing, this is installed by `libgoogle-cloud-pubsub`.
    ;;
  libgoogle-cloud-*-devel)
    feature=${PKG_NAME/#libgoogle-cloud-/}
    feature=${feature/%-devel/}
    cmake --install .build/${feature} --component google_cloud_cpp_development
    ;;
  libgoogle-cloud-*)
    feature=${PKG_NAME/#libgoogle-cloud-/}
    cmake --install .build/${feature} --component google_cloud_cpp_runtime
    ;;
esac
