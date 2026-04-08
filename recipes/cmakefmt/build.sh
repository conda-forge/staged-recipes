#!/usr/bin/env bash
set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# Ensure enough Mach-O header padding for conda-build's install_name_tool
# post-processing on macOS.
if [[ "$(uname)" == "Darwin" ]]; then
  export RUSTFLAGS="${RUSTFLAGS:-} -C link-args=-Wl,-headerpad_max_install_names"
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --root "${PREFIX}" --path .

# Shell completions
"${PREFIX}/bin/cmakefmt" --generate-completion bash > cmakefmt.bash
"${PREFIX}/bin/cmakefmt" --generate-completion zsh > _cmakefmt
"${PREFIX}/bin/cmakefmt" --generate-completion fish > cmakefmt.fish

mkdir -p "${PREFIX}/share/bash-completion/completions"
mkdir -p "${PREFIX}/share/zsh/site-functions"
mkdir -p "${PREFIX}/share/fish/vendor_completions.d"
mkdir -p "${PREFIX}/share/man/man1"

install -m644 cmakefmt.bash "${PREFIX}/share/bash-completion/completions/cmakefmt"
install -m644 _cmakefmt "${PREFIX}/share/zsh/site-functions/_cmakefmt"
install -m644 cmakefmt.fish "${PREFIX}/share/fish/vendor_completions.d/cmakefmt.fish"

# Man page
"${PREFIX}/bin/cmakefmt" --generate-man-page > cmakefmt.1
install -m644 cmakefmt.1 "${PREFIX}/share/man/man1/cmakefmt.1"
