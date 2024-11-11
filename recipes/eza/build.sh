#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --no-track --locked --root "$PREFIX" --path .

# Install shell completions
mkdir -p \
    ${PREFIX}/etc/bash_completion.d \
    ${PREFIX}/share/fish/vendor_completions.d \
    ${PREFIX}/share/zsh/site-functions

cp completions/bash/eza ${PREFIX}/etc/bash_completion.d/
cp completions/zsh/_eza ${PREFIX}/share/zsh/site-functions/
cp completions/fish/eza.fish ${PREFIX}/share/fish/vendor_completions.d/
