#!/bin/bash

set -ex

cd $SRC_DIR
go build -ldflags "-X main.revision=conda-forge" -v -o $PREFIX/bin/jd
go-licenses save . --save_path ./library_licenses