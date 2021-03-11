#!/usr/bin/env bash
set -eux

export GOPATH="$( pwd )"
export CGO_ENABLED=0
export CGO_CFLAGS="${CFLAGS}"
export CGO_CXXFLAGS="${CPPFLAGS}"
export CGO_LDFLAGS="${LDFLAGS}"
export GOFLAGS="-buildmode=pie -trimpath -ldflags=-linkmode=external -mod=vendor -modcacherw"

# the only omission from the unix build, needs investigation
# export GOTAGS="openssl"

module='github.com/ipfs/go-ipfs'

make -C "src/${module}" install nofuse

bash $RECIPE_DIR/build_library_licenses.sh
