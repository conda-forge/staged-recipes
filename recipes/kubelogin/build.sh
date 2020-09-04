#!/bin/bash

BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GO_VERSION=$(go version | cut -d " " -f 3)
LDFLAGS="-X main.version=$PKG_VERSION -X main.goVersion=$GO_VERSION -X main.buildTime=$BUILD_TIME"

go build -v -o ${target_gobin}${PKG_NAME}${target_goexe} -ldflags $LDFLAGS
