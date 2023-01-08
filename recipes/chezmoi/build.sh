#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w -X main.version=${PKG_VERSION}"
go build -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
install -Dm 644 completions/chezmoi-completion.bash ${PREFIX}/etc/bash_completion.d/chezmoi-completion.bash
install -Dm 644 completions/chezmoi.fish ${PREFIX}/share/fish/vendor_completions.d/chezmoi.fish
install -Dm 644 completions/chezmoi.zsh ${PREFIX}/share/zsh/site-functions/_chezmoi
