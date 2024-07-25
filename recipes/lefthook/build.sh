#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -trimpath -buildmode=pie -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w"
go-licenses save . --save_path=license-files

mkdir -p ${PREFIX}/etc/bash_completion.d 
mkdir -p ${PREFIX}/fish/vendor_completions.d 
mkdir -p ${PREFIX}/zsh/site-functions
lefthook completion bash > ${PREFIX}/etc/bash_completion.d/lefthook
lefthook completion fish > ${PREFIX}/fish/vendor_completions.d/lefthook.fish
lefthook completion zsh > ${PREFIX}/zsh/site-functions/_lefthook
