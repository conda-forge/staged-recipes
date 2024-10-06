#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export BTM_GENERATE="true"
cargo install --bins --no-track --locked --root ${PREFIX} --path .

out_dir=target/tmp/bottom
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/man/man1
install -m 644 ${out_dir}/completion/btm.bash ${PREFIX}/etc/bash_completion.d/btm.bash
install -m 644 ${out_dir}/completion/btm.fish ${PREFIX}/share/fish/vendor_completions.d/btm.fish
install -m 644 ${out_dir}/completion/_btm ${PREFIX}/share/zsh/site-functions/_btm
install -m 644 ${out_dir}/manpage/btm.1 ${PREFIX}/share/man/man1/btm.1

# strip debug symbols
"$STRIP" "$PREFIX/bin/btm"
