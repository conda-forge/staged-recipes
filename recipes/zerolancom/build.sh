#!/usr/bin/env bash
set -euxo pipefail

if [[ "${target_platform:-}" == osx-* ]]; then
  # std::filesystem requires macOS 10.15+ with the conda-forge SDK.
  export MACOSX_DEPLOYMENT_TARGET=10.15
fi

cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-}" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX"

cmake --build build
cmake --install build
