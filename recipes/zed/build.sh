#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# export CARGO_PROFILE_RELEASE_STRIP=symbols
# export CARGO_PROFILE_RELEASE_LTO=fat

export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="clang"
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUSTFLAGS="-C link-arg=-fuse-ld=$CONDA_PREFIX/bin/mold"

# TODO: fix that
# check licenses
# cargo-bundle-licenses \
#     --format yaml \
#     --output THIRDPARTY.yml

cargo check
#cargo install --locked --root "$PREFIX" --path zed --no-track
