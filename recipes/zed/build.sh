#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# export CARGO_PROFILE_RELEASE_STRIP=symbols
# export CARGO_PROFILE_RELEASE_LTO=fat

# export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="clang"
# export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUSTFLAGS="-C link-arg=-fuse-ld=$CONDA_PREFIX/bin/mold"

# TODO: fix that
# check licenses
# cargo-bundle-licenses \
#     --format yaml \
#     --output THIRDPARTY.yml
export CFLAGS="$CFLAGS -D_BSD_SOURCE"



cargo build --release --package zed --package cli

install -Dm0755 target/release/cli "$PREFIX/bin/cli"
install -Dm0755 target/release/zed "$PREFIX/lib/zed/zed-editor"
#install -Dm0644 crates/zed/resources/app-icon.png "$PREFIX/share/icons/zed.png"
#install -Dm0644 zed.desktop "$PREFIX/share/applications/zed.desktop"
