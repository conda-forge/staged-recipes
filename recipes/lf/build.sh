#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X main.gVersion=${PKG_VERSION}"
go-licenses save . --save_path=license-files

mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
install -m 644 ${PKG_NAME}.1 ${PREFIX}/share/man/man1/${PKG_NAME}.1
install -m 644 etc/${PKG_NAME}.zsh ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
install -m 644 etc/${PKG_NAME}.fish ${PREFIX}/share/fish/vendor_completions.d/${PKG_NAME}.fish
