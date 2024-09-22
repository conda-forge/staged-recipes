#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/gum -ldflags="-s -w -X main.Version=${PKG_VERSION}"
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader

# Manually copy licenses that go-licenses could not download
cp -r ${RECIPE_DIR}/license-files/* ${SRC_DIR}/license-files

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/man/man1
gum completion bash > ${PREFIX}/etc/bash_completion.d/gum
gum completion fish > ${PREFIX}/share/fish/vendor_completions.d/gum.fish
gum completion zsh > ${PREFIX}/share/zsh/site-functions/_gum
gum man > ${PREFIX}/share/man/man1/gum.1
