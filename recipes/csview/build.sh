#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path .

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 completions/bash/csview.bash ${PREFIX}/etc/bash_completion.d/csview.bash
install -m 644 completions/fish/csview.fish ${PREFIX}/share/fish/vendor_completions.d/csview.fish
install -m 644 completions/zsh/_csview ${PREFIX}/share/zsh/site-functions/_csview

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"
