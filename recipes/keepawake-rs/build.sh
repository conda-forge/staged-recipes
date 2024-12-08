#!/usr/bin/env bash

set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # On macos, clang 18 conflicts with Xcode_xx.x in relation to apple-sys: Use Xcode_xx.x
  export PATH="${SDKROOT}/../../../Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"
  export CPATH="${SDKROOT}/usr/include"
fi

cargo build --release --all-targets
# Skip doc-test which fails to find cc as a linker (odd, since it can build just fine)
cargo test --release --all-targets
CARGO_TARGET_DIR=target cargo install --features="bin" --path . --root "${PREFIX}"
cargo-bundle-licenses --format yaml --output "${RECIPE_DIR}"/THIRDPARTY.yml
