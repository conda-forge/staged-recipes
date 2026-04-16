#!/bin/bash
# Build script for Unix-like systems (Linux, macOS)

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses \
	--format yaml \
	--output THIRDPARTY.yml

cargo auditable install --locked --no-track --bins --root "${PREFIX}" --path .

# Create installation directories
mkdir -p "${PREFIX}/share/bash-completion/completions"
mkdir -p "${PREFIX}/share/zsh/site-functions"
mkdir -p "${PREFIX}/share/fish/vendor_completions.d"
mkdir -p "${PREFIX}/share/man/man1"
mkdir -p "${PREFIX}/share/licenses/tlrc"

# Install shell completions using `install` (source files are in completions/ subdirectory)
install -m644 completions/tldr.bash "${PREFIX}/share/bash-completion/completions/tldr"
install -m644 completions/_tldr "${PREFIX}/share/zsh/site-functions/_tldr"
install -m644 completions/tldr.fish "${PREFIX}/share/fish/vendor_completions.d/tldr.fish"

# Install man page (source file is in repository root)
install -m644 tldr.1 "${PREFIX}/share/man/man1/tldr.1"

# Install license files
install -m644 LICENSE "${PREFIX}/share/licenses/tlrc/LICENSE"
install -m644 THIRDPARTY.yml "${PREFIX}/share/licenses/tlrc/THIRDPARTY.yml"
