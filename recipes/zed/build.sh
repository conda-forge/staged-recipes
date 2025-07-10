#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml
export CFLAGS="$CFLAGS -D_BSD_SOURCE"



cargo build --release --package zed --package cli

install -Dm0755 target/${CARGO_BUILD_TARGET}/release/cli "$PREFIX/bin/zed"
install -Dm0755 target/${CARGO_BUILD_TARGET}/release/zed "$PREFIX/lib/zed/zed-editor"
