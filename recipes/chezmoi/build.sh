#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X main.version=${PKG_VERSION}"
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 completions/chezmoi-completion.bash ${PREFIX}/etc/bash_completion.d/chezmoi-completion.bash
install -m 644 completions/chezmoi.fish ${PREFIX}/share/fish/vendor_completions.d/chezmoi.fish
install -m 644 completions/chezmoi.zsh ${PREFIX}/share/zsh/site-functions/_chezmoi
