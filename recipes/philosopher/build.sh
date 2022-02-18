#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
mkdir -p $PREFIX/bin
cp -r $SRC_DIR/philosopher* $PREFIX/bin

