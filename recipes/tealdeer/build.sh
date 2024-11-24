#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path .

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 completion/bash_tealdeer ${PREFIX}/etc/bash_completion.d/tldr
install -m 644 completion/zsh_tealdeer ${PREFIX}/share/fish/vendor_completions.d/tldr.fish
install -m 644 completion/fish_tealdeer ${PREFIX}/share/zsh/site-functions/_tldr
