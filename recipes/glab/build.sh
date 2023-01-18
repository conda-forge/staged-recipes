#!/usr/bin/env bash

set -eux

module="gitlab.com/gitlab-org/cli"

export GOPATH="$( pwd )"
export GOROOT="${BUILD_PREFIX}/go"

export GOFLAGS="-buildmode=pie -trimpath -ldflags=-linkmode=external"
export GO_EXTLINK_ENABLED=1
export GO_LFFLAGS=${LDFLAGS}

export CGO_ENABLED=1
export CGO_CFLAGS="${CFLAGS}"
export CGO_CPPFLAGS="${CPPFLAGS}"
export CGO_CXXFLAGS="${CXXFLAGS}"
export CGO_LDFLAGS="${LDFLAGS}"

export GLAB_VERSION="${PKG_VERSION}"

pushd "src/${module}"
    make install
    make build
    mkdir -p "${PREFIX}/bin"
    cp "bin/${PKG_NAME}" "${PREFIX}/bin"
    go-licenses save ./cmd/glab --save_path "${SRC_DIR}/license-files"
popd

mkdir -p "${PREFIX}/share/bash-completion/completions"
"${PREFIX}/bin/${PKG_NAME}" completion -s bash > "$PREFIX/share/bash-completion/completions/${PKG_NAME}"

mkdir -p "${PREFIX}/share/fish/vendor_completions.d"
"${PREFIX}/bin/${PKG_NAME}" completion -s fish > "$PREFIX/share/fish/vendor_completions.d/${PKG_NAME}.fish"

mkdir -p "${PREFIX}/share/zsh/site-functions"
"${PREFIX}/bin/${PKG_NAME}" completion -s zsh > "$PREFIX/share/zsh/site-functions/_${PKG_NAME}"

# Make GOPATH directories writeable so conda-build can clean everything up.
find "$( go env GOPATH )" -type d -exec chmod +w {} \;
