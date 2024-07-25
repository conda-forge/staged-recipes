#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --no-track --locked --root ${PREFIX} --path .
ln -sf ${PREFIX}/bin/xh ${PREFIX}/bin/xhs

mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 doc/xh.1 ${PREFIX}/share/man/man1/xh.1
install -m 644 completions/xh.bash ${PREFIX}/etc/bash_completion.d/xh.bash
install -m 644 completions/xh.fish ${PREFIX}/share/fish/vendor_completions.d/xh.fish
install -m 644 completions/_xh ${PREFIX}/share/zsh/site-functions/_xh

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"
