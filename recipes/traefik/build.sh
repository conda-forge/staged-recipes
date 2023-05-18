#!/usr/bin/env bash
set -eux

# uses about 2gb
export TMPDIR="$( pwd )/tmp"
mkdir -p "${TMPDIR}"


export GOPATH="$( pwd )"
export GOFLAGS="-buildmode=pie -trimpath -mod=vendor -modcacherw -ldflags=-linkmode=external"
# consumed by `scripts/binary` below to avoid wrangling versioned flags
export VERSION="${PKG_VERSION}"
export DATE="$(date -u '+%Y-%m-%d_%I:%M:%S%p')"

module='github.com/traefik/traefik'

cd "src/${module}"

go mod vendor

bash script/binary

mkdir -p ${PREFIX}/bin

cp dist/traefik ${PREFIX}/bin

go-licenses save \
    "." \
    --save_path "${SRC_DIR}/library_licenses/" \
    2>&1 \
    | tee "${SRC_DIR}/go-licenses.log" \
    || echo "some errors: captured in go-licenses.log"
