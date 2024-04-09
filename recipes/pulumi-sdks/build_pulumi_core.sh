#!/bin/bash

set -exuo pipefail

mkdir -p gopath/bin
export GOPATH=$(pwd)/gopath

export PULUMI_VERSION=${PKG_VERSION}
export PULUMI_ROOT=${PREFIX}

make build
make install

chmod -R u+w ${GOPATH}

go-licenses save . --save_path=../license-file --ignore github.com/pulumi/pulumi
