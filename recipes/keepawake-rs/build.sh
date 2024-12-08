#!/usr/bin/env bash

set -euxo pipefail

# Use Conda Rust source libraries (compiled/tested) instead of downloading from crates.io
if [[ "${target_platform}" == osx-* ]]; then
  APPLE_SYS_VERSION=$(find $BUILD_PREFIX/src/rust-libraries/apple-sys-rust-source-* -type d -exec basename {} \; | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | sort -V | tail -n1)

  mkdir -p .cargo
  touch .cargo/config.toml
  cat >> .cargo/config.toml << EOF

[patch.crates-io]
apple-sys = { path = "${BUILD_PREFIX}/src/rust-libraries/apple-sys-rust-source-${APPLE_SYS_VERSION}" }
EOF
fi

# On macos, clang 18 conflicts with Xcode_15.2
if [[ "${target_platform}" == osx-* ]]; then
  export PATH="/Applications/Xcode_15.2.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"
  export CPATH="/Applications/Xcode_15.2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include"
  unset CONDA_BUILD_SYSROOT
  export DEVELOPER_DIR=/Applications/Xcode_15.2.app/Contents/Developer
  export LIBCLANG_PATH=/Applications/Xcode_15.2.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib
  export BINDGEN_EXTRA_CLANG_ARGS="-I/Applications/Xcode_15.2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include"
fi
# if [[ "${target_platform}" == osx-* ]]; then
#   # On macos, clang 18 conflicts with Xcode_xx.x in relation to apple-sys: Use Xcode_xx.x
#   # export PATH="${SDKROOT}/../../../Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"
#   export CPATH="${SDKROOT}/usr/include"
#   unset CONDA_BUILD_SYSROOT
# fi

cargo build --release --all-targets
# Skip doc-test which fails to find cc as a linker (odd, since it can build just fine)
cargo test --release --all-targets
CARGO_TARGET_DIR=target cargo install --features="bin" --path . --root "${PREFIX}"
cargo-bundle-licenses --format yaml --output "${RECIPE_DIR}"/THIRDPARTY.yml
