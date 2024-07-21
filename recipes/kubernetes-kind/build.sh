#!/bin/bash
set -exuo pipefail

export CGO_ENABLED=0
export GO111MODULE=on

echo "PKG_VERSION = ${PKG_VERSION}"

go build \
    -v \
    -trimpath \
    -ldflags "-buildid= -w" \
    -o "${PREFIX}/bin/kind"


# save thirdparty licenses
go-licenses save . --save_path ./thirdparty

# Clear out cache to avoid file not removable warnings
chmod -R u+w $(go env GOPATH) && rm -r $(go env GOPATH)
