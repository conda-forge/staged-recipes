#!/bin/bash

set -ex

export GO111MODULE=on

cd $SRC_DIR
go build -ldflags "-X main.revision=conda-forge" -v -o $PREFIX/bin/hugo
go-licenses save . --save_path ./library_licenses