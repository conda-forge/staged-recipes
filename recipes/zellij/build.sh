#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --path .
install -Dd ${PREFIX}/etc/bash_completion.d ${PREFIX}/share/fish/vendor_completions.d ${PREFIX}/share/zsh/site-functions
zellij setup --generate-completion bash > ${PREFIX}/etc/bash_completion.d/zellij
zellij setup --generate-completion fish > ${PREFIX}/share/fish/vendor_completions.d/zellij.fish
zellij setup --generate-completion zsh > ${PREFIX}/share/zsh/site-functions/_zellij
