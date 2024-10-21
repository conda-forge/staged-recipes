#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -trimpath -buildmode=pie -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X 'github.com/ferama/rospo/cmd.Version=${PKG_VERSION}'"
go-licenses save . --save_path=license-files

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
rospo completion bash > ${PREFIX}/etc/bash_completion.d/rospo
rospo completion fish > ${PREFIX}/share/fish/vendor_completions.d/rospo.fish
rospo completion zsh > ${PREFIX}/share/zsh/site-functions/_rospo
