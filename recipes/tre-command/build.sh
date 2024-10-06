#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path .

mkdir -p ${PREFIX}/share/man/man1
install -m 644 manual/tre.1 ${PREFIX}/share/man/man1/tre.1

# strip debug symbols
"$STRIP" "$PREFIX/bin/tre"
