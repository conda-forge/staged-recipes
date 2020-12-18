#!/usr/bin/env bash

# Build
go build -v -o ${PKG_NAME} -ldflags="-s -w -X main.version=${PKG_VERSION}" .

# Install Binary into PREFIX/bin
mkdir -p $PREFIX/bin
mv ${PKG_NAME} $PREFIX/bin/${PKG_NAME}
