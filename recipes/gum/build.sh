#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X main.Version=${PKG_VERSION}"
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader

# Manually copy licenses that go-licenses could not download
cp -r ${RECIPE_DIR}/license-files/* ${SRC_DIR}/license-files

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/man/man1
${PKG_NAME} completion bash > ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
${PKG_NAME} completion fish > ${PREFIX}/share/fish/vendor_completions.d/${PKG_NAME}.fish
${PKG_NAME} completion zsh > ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
${PKG_NAME} man > ${PREFIX}/share/man/man1/${PKG_NAME}.1
