#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path cli
./documentation/build.sh
mkdir -p ${PREFIX}/share/man/man1
install -m 644 documentation/fend.1 ${PREFIX}/share/man/man1/fend.1

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"
