#!/bin/bash

# Stop on first error
set -euo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # as in build.sh
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Use shell expansion to temove any `libgoogle-cloud-` prefix and the `-devel`
# suffix from PKG_NAME and find the feature name.
#     https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
feature=${PKG_NAME/#libgoogle-cloud-/}
feature=${feature/%-devel/}

cmake -GNinja \
    -S "google/cloud/${feature}/quickstart" -B build \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_MODULE_PATH="$PREFIX/lib/cmake"
cmake --build build
