#!/usr/bin/env bash
set -eux

module="github.com/errata-ai/vale"

export GOPATH="$( pwd )"
export GOROOT="${BUILD_PREFIX}/go"
export GOOS=windows
export GOARCH=amd64
export CGO_ENABLED=1
export GO111MODULE=on

pushd "src/${module}"
    go get -u -v "./cmd/${PKG_NAME}"
    go build \
        -ldflags "-s -w -X main.version=${PKG_VERSION}" \
        -o "${PREFIX}/bin/${PKG_NAME}.exe" \
        "./cmd/${PKG_NAME}" \
        || exit 1
    # except the first, all --ignores are stdlib, found for some reason
    go-licenses save "./cmd/${PKG_NAME}" \
        --save_path "${SRC_DIR}/license-files" \
        --ignore=github.com/xi2/xz \
        --ignore=archive/tar \
        --ignore=bufio \
        --ignore=bytes \
        --ignore=compress/flate \
        --ignore=compress/gzip \
        --ignore=context \
        --ignore=crypto \
        --ignore=crypto/aes \
        --ignore=crypto/cipher \
        --ignore=crypto/dsa \
        --ignore=crypto/ecdsa \
        --ignore=crypto/ed25519 \
        --ignore=database/sql/driver \
        --ignore=embed \
        --ignore=encoding \
        --ignore=encoding/csv \
        --ignore=errors \
        --ignore=flag \
        --ignore=fmt \
        --ignore=hash/adler32 \
        --ignore=hash/crc32 \
        --ignore=hash/crc64 \
        --ignore=html \
        --ignore=internal/bytealg \
        --ignore=internal/coverage/rtcov \
        --ignore=internal/cpu \
        --ignore=internal/goarch \
        --ignore=internal/goexperiment \
        --ignore=internal/goos \
        --ignore=internal/oserror \
        --ignore=internal/race \
        --ignore=internal/saferio \
        --ignore=internal/syscall/windows \
        --ignore=internal/syscall/windows/registry \
        --ignore=internal/sysinfo \
        --ignore=io \
        --ignore=io/fs \
        --ignore=log \
        --ignore=math \
        --ignore=net \
        --ignore=net/http \
        --ignore=net/url \
        --ignore=os/exec \
        --ignore=os/signal \
        --ignore=os/user \
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
        --ignore=syscall \
        --ignore=testing \
        --ignore=text/tabwriter \
        --ignore=text/template \
        --ignore=text/template/parse \
        --ignore=time \
        --ignore=unicode \
        --ignore=unicode/utf16 \
        --ignore=unicode/utf8 \
        --ignore=vendor/golang.org/x/crypto/cryptobyte \
        --ignore=vendor/golang.org/x/crypto/cryptobyte/asn1 \
        || exit 1
popd

# Make GOPATH directories writeable so conda-build can clean everything up.
find "$( go env GOPATH )" -type d -exec chmod +w {} \;
