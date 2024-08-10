#!/bin/sh

export GO111MODULE=on

mv ${SRC_DIR} ${GOPATH}/src
cd ${GOPATH}/src/peco

make build

go build \
    -ldflags "-s -w -X main.Version=${PKG_VERSION}" \
    -o ${PREFIX}/bin/${PKG_NAME} \
    cmd/${PKG_NAME}/${PKG_NAME}.go
