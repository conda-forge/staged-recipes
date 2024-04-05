#!/bin/bash

set -exuo pipefail

mkdir -p gopath/bin
export GOPATH=$(pwd)/gopath

export PULUMI_VERSION=${PKG_VERSION}
export PULUMI_ROOT=${PREFIX}

make -C sdk/nodejs build
make -C sdk/nodejs install

chmod -R u+w ${GOPATH}
