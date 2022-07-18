#!/usr/bin/env bash
set -eux

export GOPATH="$( pwd )"

module='github.com/minio/minio'

pushd "src/${module}"
    pwd
    ls -lah
    go build -o $PREFIX/bin/minio .
popd

pushd "src/${module}"
    mkdir -p ${PREFIX}/bin
    cp cmd/ipfs/ipfs ${PREFIX}/bin
    bash $RECIPE_DIR/build_library_licenses.sh
popd
