#!/usr/bin/env bash
set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --root "${PREFIX}" --path .

# Shell completions
"${PREFIX}/bin/cmakefmt" --generate-completion bash > cmakefmt.bash
"${PREFIX}/bin/cmakefmt" --generate-completion zsh > _cmakefmt
"${PREFIX}/bin/cmakefmt" --generate-completion fish > cmakefmt.fish

install -Dm644 cmakefmt.bash "${PREFIX}/share/bash-completion/completions/cmakefmt"
install -Dm644 _cmakefmt "${PREFIX}/share/zsh/site-functions/_cmakefmt"
install -Dm644 cmakefmt.fish "${PREFIX}/share/fish/vendor_completions.d/cmakefmt.fish"

# Man page
"${PREFIX}/bin/cmakefmt" --generate-man-page > cmakefmt.1
install -Dm644 cmakefmt.1 "${PREFIX}/share/man/man1/cmakefmt.1"
