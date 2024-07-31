#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X github.com/apache/skywalking-eyes/commands.version=${PKG_VERSION}" ./cmd/license-eye
go-licenses save ./cmd/license-eye --save_path=license-files
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
skywalking-eyes completion bash > ${PREFIX}/etc/bash_completion.d/skywalking-eyes
skywalking-eyes completion fish > ${PREFIX}/share/fish/vendor_completions.d/skywalking-eyes.fish
skywalking-eyes completion zsh > ${PREFIX}/share/zsh/site-functions/_skywalking-eyes
