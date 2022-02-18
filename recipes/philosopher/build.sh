#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
mkdir -p $PREFIX/bin
cp $SRC_DIR/philosopher* $PREFIX/bin

