#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export SHELL_COMPLETIONS_DIR=${BUILD_PREFIX}
cargo install --bins --no-track --locked --root ${PREFIX} --path .

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
fingerprint_dir=$(dirname $(find . -path "*/rnr-*/out" | head -n 1))
install -m 644 ${fingerprint_dir}/out/rnr.bash ${PREFIX}/etc/bash_completion.d/rnr
install -m 644 ${fingerprint_dir}/out/rnr.fish ${PREFIX}/share/fish/vendor_completions.d
install -m 644 ${fingerprint_dir}/out/_rnr ${PREFIX}/share/zsh/site-functions
