#!/usr/bin/env bash
set -eux

module="gitlab.com/gitlab-org/cli"

export GOPATH="$( pwd )"
export GOROOT="${BUILD_PREFIX}/go"
export GOOS=windows 
export GOARCH=amd64
export CGO_ENABLED=1

export GLAB_VERSION="${PKG_VERSION}"

mkdir -p "${PREFIX}/bin"

pushd "src/${module}"
    make install
    make build
    cp "bin/glab" "${PREFIX}/bin/glab.exe"
    go-licenses save ./cmd/glab --save_path "${SRC_DIR}/license-files"
popd

mkdir -p "${PREFIX}/share/bash-completion/completions"
"${PREFIX}/bin/${PKG_NAME}" completion -s bash > "$PREFIX/share/bash-completion/completions/glab"

mkdir -p "${PREFIX}/share/fish/vendor_completions.d"
"${PREFIX}/bin/${PKG_NAME}" completion -s fish > "$PREFIX/share/fish/vendor_completions.d/glab.fish"

mkdir -p "${PREFIX}/share/zsh/site-functions"
"${PREFIX}/bin/${PKG_NAME}" completion -s zsh > "$PREFIX/share/zsh/site-functions/_glab"

# Make GOPATH directories writeable so conda-build can clean everything up.
find "$( go env GOPATH )" -type d -exec chmod +w {} \;
