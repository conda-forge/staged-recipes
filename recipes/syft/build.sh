#!/bin/bash
set -exuo pipefail

pushd src/cmd/syft

go-licenses save . --save_path ../../../library_licenses --ignore modernc.org/mathutil --ignore github.com/xi2/xz
export GOFLAGS='-tags=duckdb_use_lib,dynamic'
go build \
    -v \
    -o $PREFIX/bin/syft \
    -ldflags="-X 'main.version=${PKG_VERSION}'"

popd

# Clear out cache to avoid file not removable warnings
chmod -R u+w $(go env GOPATH) && rm -r $(go env GOPATH)
