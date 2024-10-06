#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path .
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/man/man1
install -m 644 gen/completions/sd.fish ${PREFIX}/share/fish/vendor_completions.d/sd.fish
install -m 644 gen/completions/_sd ${PREFIX}/share/zsh/site-functions/_sd
install -m 644 gen/sd.1 ${PREFIX}/share/man/man1/sd.1

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"
