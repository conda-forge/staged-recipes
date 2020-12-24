#!/usr/bin/env bash
#http://redsymbol.net/articles/unofficial-bash-strict-mode/

set -euo pipefail
IFS=$'\n\t'

set -x


# Turn work folder into GOPATH
export GOPATH=$SRC_DIR
export PATH=${GOPATH}/bin:$PATH

# Change to directory with main.go
pushd src/github.com/bazelbuild/buildtools/buildifier

# Build
go get .
go build -v -o ${PKG_NAME} -ldflags "-X main.buildVersion=${PKG_VERSION}" .

# Install Binary into PREFIX/bin
mkdir -p $PREFIX/bin
mv ${PKG_NAME} $PREFIX/bin/${PKG_NAME}
