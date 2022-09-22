#!/usr/bin/env bash
set -eux

export GOPATH="$( pwd )"
export CGO_ENABLED=1
export CGO_CFLAGS="${CFLAGS}"
export CGO_LDFLAGS="${LDFLAGS}"
export GOFLAGS="-buildmode=pie -trimpath -ldflags=-linkmode=external -mod=vendor -modcacherw"
export GOTAGS="openssl"

module='github.com/ipfs/kubo'

if [ $(uname) == Darwin ]; then
    export CGO_CFLAGS="-I${PREFIX}/include/ ${CGO_CFLAGS}"
    export CGO_LDFLAGS="-L${PREFIX}/lib/ ${CGO_LDFLAGS}"
    pushd "src/${module}/vendor/github.com/libp2p/go-openssl"
        sed -i '' -e "s|/usr/local/opt/openssl@1.1|${PREFIX}|g" build.go
        sed -i '' -e "s|-I/usr/local/opt/openssl/include||" build.go
        sed -i '' -e "s|-L/usr/local/opt/openssl/lib||" build.go
        cat build.go
    popd
fi

make -C "src/${module}" install nofuse

pushd "src/${module}"
    mkdir -p ${PREFIX}/bin
    cp cmd/ipfs/ipfs ${PREFIX}/bin
    bash $RECIPE_DIR/build_library_licenses.sh
popd
