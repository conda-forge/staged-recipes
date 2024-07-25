#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --no-track --locked --root ${PREFIX} --path .

mkdir -p ${PREFIX}/etc/bash_completion.d 
mkdir -p ${PREFIX}/share/fish/vendor_completions.d 
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/man/man1
install -m 644 Documentation/git-absorb.1 ${PREFIX}/share/man/man1/git-absorb.1
git-absorb --gen-completions bash > ${PREFIX}/etc/bash_completion.d/git-absorb
git-absorb --gen-completions fish > ${PREFIX}/share/fish/vendor_completions.d/git-absorb.fish
git-absorb --gen-completions zsh > ${PREFIX}/share/zsh/site-functions/_git-absorb

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"
