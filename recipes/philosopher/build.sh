#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
mkdir -p $PREFIX/philosopher
cp -r $SRC_DIR/* $PREFIX/philosopher

