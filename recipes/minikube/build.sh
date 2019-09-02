#!/bin/env bash

set -ex

if [ $(uname) == Darwin ]; then
  export MINIKUBE_OS=darwin
else
  export MINIKUBE_OS=linux
fi

export GOPATH="${BUILD_PREFIX}/bin"
export GOROOT="${BUILD_PREFIX}/go"

make

mkdir -p $PREFIX/bin

mv out/minikube-${MINIKUBE_OS}-amd64 $PREFIX/bin
