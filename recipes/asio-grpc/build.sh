#!/bin/bash

mkdir -p build
pushd build

cmake -G Ninja --install-prefix $PREFIX $SRC_DIR
ninja install
