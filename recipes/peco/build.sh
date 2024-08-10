#!/bin/sh

export GO111MODULE=on

cd ${SRC_DIR}

make build

go build \
    -ldflags "-s -w -X main.Version=${PKG_VERSION}" \
    -o ${PREFIX}/bin/${PKG_NAME} \
    cmd/${PKG_NAME}/${PKG_NAME}.go
