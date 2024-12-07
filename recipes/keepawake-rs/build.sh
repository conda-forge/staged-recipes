#!/usr/bin/env bash

set -euxo pipefail

# On macos, clang 18 conflicts with Xcode_15.2
if [[ "${target_platform}" == osx-* ]]; then
    unset CONDA_BUILD_SYSROOT
    export DEVELOPER_DIR=/Applications/Xcode_15.2.app/Contents/Developer
fi

cargo build --release --all-targets
# Skip doc-test which fails to find cc as a linker (odd, since it can build just fine)
cargo test --release --all-targets
CARGO_TARGET_DIR=target cargo install --features="bin" --path . --root "${PREFIX}"
cargo-bundle-licenses --format yaml --output "${RECIPE_DIR}"/THIRDPARTY.yml
