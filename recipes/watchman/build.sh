#!/usr/bin/env bash
set -euxo pipefail

# Only the watchman server is built through CMake: its default target also
# builds the unit tests, and its Rust integration assumes cargo's host target
# directory layout.
cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_DISABLE_FIND_PACKAGE_Python3=ON \
  -DENABLE_EDEN_SUPPORT=OFF \
  -DWATCHMAN_USE_XDG_STATE_HOME=ON \
  -DWATCHMAN_VERSION_OVERRIDE="${PKG_VERSION}" \
  -DWATCHMAN_BUILDINFO_OVERRIDE=conda-forge
cmake --build build --target watchman --parallel "${CPU_COUNT}"
install -Dm755 build/bin/watchman "${PREFIX}/bin/watchman"

cd watchman/cli
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"
cargo install --no-track --path . --root "${PREFIX}"
