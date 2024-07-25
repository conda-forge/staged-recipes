#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --no-track --locked --root ${PREFIX} --bin jj --path cli

mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
jj util completion --zsh > ${PREFIX}/share/zsh/site-functions/_jj
jj util completion --fish > ${PREFIX}/share/fish/vendor_completions.d/jj.fish
mkdir -p ${PREFIX}/share/man/man1
jj util mangen > ${PREFIX}/share/man/man1/jj.1

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"
