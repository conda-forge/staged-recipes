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

    # the --ignores are all stdlib, found for some reason
    go-licenses save ./cmd/glab --save_path "${SRC_DIR}/license-files" \
        --ignore=archive/zip \
        --ignore=bufio \
        --ignore=bytes \
        --ignore=context \
        --ignore=crypto/rsa \
        --ignore=crypto/tls \
        --ignore=crypto/x509 \
        --ignore=database/sql/driver \
        --ignore=encoding \
        --ignore=encoding/base64 \
        --ignore=encoding/binary \
        --ignore=encoding/csv \
        --ignore=encoding/hex \
        --ignore=encoding/json \
        --ignore=encoding/pem \
        --ignore=errors \
        --ignore=flag \
        --ignore=fmt \
        --ignore=html \
        --ignore=html/template \
        --ignore=image/color \
        --ignore=io \
        --ignore=io/ioutil \
        --ignore=log \
        --ignore=math \
        --ignore=math/big \
        --ignore=math/rand \
        --ignore=mime \
        --ignore=mime/multipart \
        --ignore=net \
        --ignore=net/http \
        --ignore=net/url \
        --ignore=os \
        --ignore=os/exec \
        --ignore=path \
        --ignore=path/filepath \
        --ignore=reflect \
        --ignore=regexp \
        --ignore=runtime \
        --ignore=runtime/debug \
        --ignore=sort \
        --ignore=strconv \
        --ignore=strings \
        --ignore=sync \
        --ignore=sync/atomic \
        --ignore=syscall \
        --ignore=text/template \
        --ignore=time \
        --ignore=unicode \
        --ignore=unicode/utf16 \
        --ignore=unicode/utf8
popd

mkdir -p "${PREFIX}/share/bash-completion/completions"
"${PREFIX}/bin/${PKG_NAME}" completion -s bash > "$PREFIX/share/bash-completion/completions/glab"

mkdir -p "${PREFIX}/share/fish/vendor_completions.d"
"${PREFIX}/bin/${PKG_NAME}" completion -s fish > "$PREFIX/share/fish/vendor_completions.d/glab.fish"

mkdir -p "${PREFIX}/share/zsh/site-functions"
"${PREFIX}/bin/${PKG_NAME}" completion -s zsh > "$PREFIX/share/zsh/site-functions/_glab"

# Make GOPATH directories writeable so conda-build can clean everything up.
find "$( go env GOPATH )" -type d -exec chmod +w {} \;
