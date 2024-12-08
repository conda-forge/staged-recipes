#!/usr/bin/env bash

set -euxo pipefail

# Use Conda Rust source libraries (compiled/tested) instead of downloading from crates.io
EGUI_PHOSPHOR_VERSION=$(find $BUILD_PREFIX/src/rust-libraries/egui-phosphor-rust-source-* -type d -exec basename {} \; | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | sort -V | tail -n1)
PREFERENCES_VERSION=$(find $BUILD_PREFIX/src/rust-libraries/preferences-rs-rust-source-* -type d -exec basename {} \; | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | sort -V | tail -n1)
SERIALPORT_VERSION=$(find $BUILD_PREFIX/src/rust-libraries/serialport-rs-rust-source-* -type d -exec basename {} \; | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | sort -V | tail -n1)

mkdir -p .cargo
touch .cargo/config.toml
cat >> .cargo/config.toml << EOF

[patch.crates-io]
serialport = { path = "${BUILD_PREFIX}/src/rust-libraries/serialport-rs-rust-source-${SERIALPORT_VERSION}" }
egui-phosphor = { path = "${BUILD_PREFIX}/src/rust-libraries/egui-phosphor-rust-source-${EGUI_PHOSPHOR_VERSION}" }
preferences = { path = "${BUILD_PREFIX}/src/rust-libraries/preferences-rs-rust-source-${PREFERENCES_VERSION}" }
EOF

if [[ "${target_platform}" == osx-* ]]; then
  # On macos, clang 18 conflicts with Xcode_xx.x in relation to apple-sys: Use Xcode_xx.x
  export PATH="${SDKROOT}/../../../Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"
  export CPATH="${SDKROOT}/usr/include"
fi

cargo build --release --all-targets
cargo test --release --all-targets
CARGO_TARGET_DIR=target cargo install --path . --root "${PREFIX}"
cargo-bundle-licenses --format yaml --output "${RECIPE_DIR}"/THIRDPARTY.yml
