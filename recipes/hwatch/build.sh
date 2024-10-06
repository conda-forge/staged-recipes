#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path .

mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 man/hwatch.1 ${PREFIX}/share/man/man1/hwatch.1
install -m 644 completion/bash/hwatch-completion.bash ${PREFIX}/etc/bash_completion.d/hwatch
install -m 644 completion/fish/hwatch.fish ${PREFIX}/share/fish/vendor_completions.d/hwatch.fish
install -m 644 completion/zsh/_hwatch ${PREFIX}/share/zsh/site-functions/_hwatch

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"
