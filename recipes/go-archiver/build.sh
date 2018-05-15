#!/bin/bash

# go one level up
cd $SRC_DIR
cd ..

# create the gopath directory structure
export GOPATH=$PWD/gopath
mkdir -p $GOPATH/src/github.com/mholt
cp -rv $SRC_DIR $GOPATH/src/github.com/mholt/archiver
cd $GOPATH/src/github.com/mholt/archiver

# build the project
cd cmd/archiver/
go get -v
go build

# install the binary
mkdir -p $PREFIX/bin
mv $GOPATH/bin/archiver $PREFIX/bin
