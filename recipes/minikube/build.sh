#!/bin/env bash

set -ex

export GOPATH="${BUILD_PREFIX}/bin"
export GOROOT="${BUILD_PREFIX}/go"

make

mkdir -p $PREFIX/bin

mv out/minikube $PREFIX/bin
