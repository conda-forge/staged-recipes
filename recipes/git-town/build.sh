#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -trimpath -buildmode=pie -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w"
go-licenses save . --save_path=license-files

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/fish/vendor_completions.d
mkdir -p ${PREFIX}/zsh/site-functions
${PKG_NAME} completions bash > ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
${PKG_NAME} completions fish > ${PREFIX}/fish/vendor_completions.d/${PKG_NAME}.fish
${PKG_NAME} completions zsh > ${PREFIX}/zsh/site-functions/_${PKG_NAME}
