#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --no-track --locked --root ${PREFIX} --path .

# Install completions
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 etc/completion/completion.bash ${PREFIX}/etc/bash_completion.d/delta
install -m 644 etc/completion/completion.fish ${PREFIX}/share/fish/vendor_completions.d/delta.fish
install -m 644 etc/completion/completion.zsh ${PREFIX}/share/zsh/site-functions/_delta

# strip debug symbols
"$STRIP" "$PREFIX/bin/delta"
