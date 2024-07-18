#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" ./cmd/colima
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
colima completion bash > ${PREFIX}/etc/bash_completion.d/lima
colima completion zsh > ${PREFIX}/share/zsh/site-functions/_lima
colima completion fish > ${PREFIX}/share/fish/vendor_completions.d/lima.fish

go-licenses save ./cmd/colima --save_path=license-files
