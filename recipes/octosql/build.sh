#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X github.com/cube2222/octosql/cmd.VERSION=${PKG_VERSION}"
go-licenses save . --save_path=license-files --ignore github.com/cube2222/octosql --ignore github.com/xi2/xz

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
octosql completion bash > ${PREFIX}/etc/bash_completion.d/octosql
octosql completion fish > ${PREFIX}/share/fish/vendor_completions.d/octosql.fish
octosql completion zsh > ${PREFIX}/share/zsh/site-functions/_octosql
