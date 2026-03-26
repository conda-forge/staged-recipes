#!/bin/bash
set -exo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo auditable install --locked --root ${PREFIX} --path .

# Install man page
mkdir -p "${PREFIX}/share/man/man1"
install -m 644 docs/taskwarrior-tui.1 "${PREFIX}/share/man/man1/"

# Install shell completions
mkdir -p "${PREFIX}/share/bash-completion/completions"
install -m 644 completions/taskwarrior-tui.bash "${PREFIX}/share/bash-completion/completions/taskwarrior-tui"

mkdir -p "${PREFIX}/share/fish/vendor_completions.d"
install -m 644 completions/taskwarrior-tui.fish "${PREFIX}/share/fish/vendor_completions.d/"

mkdir -p "${PREFIX}/share/zsh/site-functions"
install -m 644 completions/_taskwarrior-tui "${PREFIX}/share/zsh/site-functions/"
