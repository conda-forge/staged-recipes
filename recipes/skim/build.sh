#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path ${SRC_DIR}

mkdir -p ${PREFIX}/share/${PKG_NAME}
cp -r install ${PREFIX}/share/${PKG_NAME}
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/man/man1
install -m 644 shell/key-bindings.bash ${PREFIX}/etc/bash_completion.d/key-bindings.bash
install -m 644 shell/completion.bash ${PREFIX}/etc/bash_completion.d/completion.bash
install -m 644 shell/key-bindings.fish ${PREFIX}/share/fish/vendor_completions.d/skim.fish
install -m 644 shell/key-bindings.zsh ${PREFIX}/share/zsh/site-functions/key-bindings.zsh
install -m 644 shell/completion.zsh ${PREFIX}/share/zsh/site-functions/completions.zsh
install -m 644 man/man1/sk.1 ${PREFIX}/share/man/man1/sk.1
install -m 644 man/man1/sk-tmux.1 ${PREFIX}/share/man/man1/sk-tmux.1
install -m 755 bin/sk-tmux ${PREFIX}/bin/sk-tmux
