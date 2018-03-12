#!/usr/bin/env bash

# Create temporary GOPATH
mkdir build
export GOPATH=$(pwd)/build
mkdir -p $GOPATH/src/github.com/terraform-providers

# Link code to GOPATH directory
ln -s $(pwd) $GOPATH/src/github.com/terraform-providers/$PKG_NAME

# Build
cd $GOPATH/src/github.com/terraform-providers/$PKG_NAME
make build
make test

# Install Binary into PREFIX/bin
mv $GOPATH/bin/$PKG_NAME $PREFIX/bin/${PKG_NAME}_v${PKG_VERSION}_x4
