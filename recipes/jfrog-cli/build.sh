#!/bin/bash

set -ex

# export GO111MODULE=on

cd $SRC_DIR
go build -ldflags "-X main.revision=conda-forge" -v -o $PREFIX/bin/jf
go-licenses save . --ignore "github.com/xi2/xz" --save_path ./library_licenses
