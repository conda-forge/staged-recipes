#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

export LIBGIT2_NO_VENDOR=1

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 completions/bash/eza ${PREFIX}/etc/bash_completion.d
install -m 644 completions/fish/eza.fish ${PREFIX}/share/fish/vendor_completions.d
install -m 644 completions/zsh/_eza ${PREFIX}/share/zsh/site-functions

pandoc --standalone --from=markdown --to=man man/eza.1.md -o eza.1
pandoc --standalone --from=markdown --to=man man/eza_colors.5.md -o eza_colors.5
pandoc --standalone --from=markdown --to=man man/eza_colors-explanation.5.md -o eza_colors-explanation.5
mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/share/man/man5
install -m 644 eza.1 ${PREFIX}/share/man/man1
install -m 644 eza_colors.5 ${PREFIX}/share/man/man5
install -m 644 eza_colors-explanation.5 ${PREFIX}/share/man/man5
