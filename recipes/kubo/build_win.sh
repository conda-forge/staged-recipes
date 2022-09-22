#!/usr/bin/env bash
set -eux

export GOPATH="$( pwd )"
export CGO_ENABLED=0
export GOFLAGS="-buildmode=pie -trimpath -ldflags=-linkmode=external -mod=vendor -modcacherw"

# omissions from the unix build, needs investigation
# export GOTAGS="openssl"
# export CGO_CFLAGS="${CFLAGS}"
# export CGO_CXXFLAGS="${CPPFLAGS}"
# export CGO_LDFLAGS="${LDFLAGS}"

module='github.com/ipfs/kubo'

make -C "src/${module}" install nofuse

pushd "src/${module}"
    bash $RECIPE_DIR/build_library_licenses.sh
popd
