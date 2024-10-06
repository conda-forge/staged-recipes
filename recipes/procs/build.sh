#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path .

procs --gen-completion bash
procs --gen-completion fish
procs --gen-completion zsh
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 procs.bash ${PREFIX}/etc/bash_completion.d/procs.bash
install -m 644 procs.fish ${PREFIX}/share/fish/vendor_completions.d/procs.fish
install -m 644 _procs ${PREFIX}/share/zsh/site-functions/_procs

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"
