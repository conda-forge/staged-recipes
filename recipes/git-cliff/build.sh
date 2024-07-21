#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --path ${PKG_NAME}

export OUT_DIR=$SRC_DIR
${PKG_NAME}-completions
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 ${PKG_NAME}.fish ${PREFIX}/share/fish/vendor_completions.d/${PKG_NAME}.fish
install -m 644 _${PKG_NAME} ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"
"$STRIP" "$PREFIX/bin/${PKG_NAME}-completions"
"$STRIP" "$PREFIX/bin/${PKG_NAME}-mangen"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
