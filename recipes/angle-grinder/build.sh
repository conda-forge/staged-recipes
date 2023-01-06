#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export JEMALLOC_SYS_WITH_LG_VADDR=48
cargo install --locked --root "${PREFIX}" --path .

# strip debug symbols
"${STRIP}" "${PREFIX}/bin/agrind"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
