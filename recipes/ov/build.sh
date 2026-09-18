#!/bin/bash
set -o xtrace -o nounset -o pipefail -o errexit

GO_LDFLAGS="-X main.Version=${PKG_VERSION} -X main.Revision=conda-forge"

go build -v -ldflags "${GO_LDFLAGS}" -o $PREFIX/bin/ov .
go-licenses save . --save_path="./license-files"

mkdir -p "$PREFIX/share/bash-completion/completions"
mkdir -p "$PREFIX/share/zsh/site-functions"
mkdir -p "$PREFIX/share/fish/vendor_completions.d"

$PREFIX/bin/ov --completion bash >"$PREFIX/share/bash-completion/completions/ov"
$PREFIX/bin/ov --completion zsh >"$PREFIX/share/zsh/site-functions/_ov"
$PREFIX/bin/ov --completion fish >"$PREFIX/share/fish/vendor_completions.d/ov.fish"
