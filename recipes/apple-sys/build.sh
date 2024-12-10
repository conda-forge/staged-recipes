#!/usr/bin/env bash

set -euxo pipefail

export CLANG_PATH="${BUILD_PREFIX}/bin/clang"
export BINDGEN_EXTRA_CLANG_ARGS="-isysroot ${SDKROOT}"
export CPATH="${SDKROOT}/usr/include"
export PATH="${BUILD_PREFIX}/bin:${PATH}"
unset DEVELOPER_DIR
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
export BINDGEN_EXTRA_CLANG_ARGS="-isysroot ${SDKROOT} -I${BUILD_PREFIX}/lib/clang/18/include -iframework ${SDKROOT}/System/Library/Frameworks"

export RUST_BACKTRACE=1
export BINDGEN_LOG=debug
export LIBCLANG_LOGGING=1

SDK_PATH=${SDKROOT}/System/Library/Frameworks
# echo "=== CoreFoundation Framework Structure ==="
# find ${SDK_PATH}/CoreFoundation.framework -type f -o -type l | sort
#
# echo -e "\n=== Module Maps ==="
# find ${SDK_PATH} -name "module*.map" -o -name "module*.modulemap" | while read map; do
#     echo -e "\n>>> $map:"
#     head -n 20 "$map"
#     echo "..."
# done
#
# echo -e "\n=== Framework Headers ==="
# find ${SDK_PATH}/CoreFoundation.framework -name "*.h" | while read header; do
#     echo -e "\n>>> $header:"
#     head -n 5 "$header"
#     echo "..."
# done

cargo fix --lib -p apple-bindgen --allow-no-vcs
cargo build --release --manifest-path=bindgen/Cargo.toml --features=bin
export RUST_LOG=debug
export RUST_BACKTRACE=full
cargo test --release --manifest-path=bindgen/Cargo.toml --features=bin -- --nocapture
CARGO_TARGET_DIR=target cargo install --features=bin --path bindgen --root "${PREFIX}"

# Create conda local source for apple-sys
source ./apple-sys-features.sh
failed_features=()
for feature in "${features[@]}"; do
  if ! cargo build --manifest-path=sys/Cargo.toml --features "$feature"; then
    echo "Warning: Failed to build feature $feature"
    failed_features+=("$feature")
  fi
done

# Print failed features for reference but don't fail the build
if [ ${#failed_features[@]} -ne 0 ]; then
  echo "The following features failed to build:"
  printf '%s\n' "${failed_features[@]}"
fi

mkdir -p "${PREFIX}/src/rust-libraries/${PKG_NAME}-${PKG_VERSION}"
cp -r ./* "${PREFIX}/src/rust-libraries/${PKG_NAME}-${PKG_VERSION}"

# Adding the checksums of the source distribution to the recipe
PKG_SHA256=$(tar -c . | sha256sum | cut -d ' ' -f 1)
cat > $PREFIX/src/rust-libraries/${PKG_NAME}-${PKG_VERSION}/.cargo-checksum.json << EOF
{"files":{},"package":"${PKG_SHA256}"}
EOF

cargo-bundle-licenses --format yaml --output "${RECIPE_DIR}"/THIRDPARTY.yml
