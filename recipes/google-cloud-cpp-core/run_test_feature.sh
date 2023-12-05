#!/bin/bash

# Stop on first error
set -euo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # as in build.sh
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

feature=${PKG_NAME/#libgoogle-cloud-/}
feature=${feature/%-devel/}

cmake -GNinja \
    -S "google/cloud/${feature}/quickstart" -B .build \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_MODULE_PATH="$PREFIX/lib/cmake"
cmake --build .build
