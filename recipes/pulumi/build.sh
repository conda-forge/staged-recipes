#!/bin/bash

set -exuo pipefail

mkdir -p gopath/bin
export GOPATH=$(pwd)/gopath

make BREW_VERSION=${PKG_VERSION} brew

rm -rf ${GOPATH}