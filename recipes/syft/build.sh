#!/bin/bash
set -exuo pipefail

pushd src/cmd/syft

go-licenses save . --save_path ../../../library_licenses --ignore modernc.org/mathutil --ignore github.com/xi2/xz

go build -v -o $PREFIX/bin/syft

popd

# Clear out cache to avoid file not removable warnings
chmod -R u+w $(go env GOPATH) && rm -r $(go env GOPATH)
