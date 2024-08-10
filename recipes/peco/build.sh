#!/bin/sh

export GO111MODULE=on
export GOPATH=${CONDA_PREFIX}/go

mkdir -p $GOPATH/src/github.com/peco
cp -r ${SRC_DIR} $GOPATH/src/github.com/peco/peco
cd $GOPATH/src/github.com/peco/peco

make build

go build \
    -ldflags "-s -w -X main.Version=${PKG_VERSION}" \
    -o ${PREFIX}/bin/${PKG_NAME} \
    cmd/${PKG_NAME}/${PKG_NAME}.go
