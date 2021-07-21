#!/usr/bin/env bash

set -eux

SOURCE_DIR=$(pwd)
BUILD_DIR=build
ECBUILD_BIN="$SOURCE_DIR/ecbuild/bin/ecbuild"

test -f $ECBUILD_BIN

cd $SOURCE_DIR/eckit

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cd $BUILD_DIR

$ECBUILD_BIN --prefix=$PREFIX -- $SOURCE_DIR/eckit
make -j $CPU_COUNT
make test -j $CPU_COUNT
make install

cd $SOURCE_DIR

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cd $BUILD_DIR

$ECBUILD_BIN --prefix=$PREFIX -- -DENABLE_FORTRAN=ON $SOURCE_DIR
make -j $CPU_COUNT
make test -j $CPU_COUNT
make install
