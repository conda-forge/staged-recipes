#!/bin/bash

set -exuo pipefail

mkdir -p gopath/bin
export GOPATH=$(pwd)/gopath

make build VERSION=${PKG_VERSION}
mkdir -p ${PREFIX}/bin
make install

chmod -R u+w ${GOPATH}