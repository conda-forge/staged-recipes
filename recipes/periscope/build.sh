#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/psc -ldflags="-s -w -X main.version=${PKG_VERSION}" ./cmd/psc
go-licenses save ./cmd/psc --save_path=license-files --ignore github.com/anishathalye/periscope

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
psc completion bash > ${PREFIX}/etc/bash_completion.d/psc
psc completion fish > ${PREFIX}/share/fish/vendor_completions.d/psc.fish
psc completion zsh > ${PREFIX}/share/zsh/site-functions/_psc
