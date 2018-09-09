#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# go one level up
cd "$SRC_DIR"
cd ..

# create the gopath directory structure
export GOPATH=$PWD/gopath
mkdir -p "$GOPATH/src/github.com/jesseduffield"
ln -s "$SRC_DIR" "$GOPATH/src/github.com/jesseduffield/lazygit"
cd "$GOPATH/src/github.com/jesseduffield/lazygit"

# build the project
go get -v
go build

# install the binary
mkdir -p "$PREFIX/bin"
mv "$GOPATH/bin/lazygit" "$PREFIX/bin"
