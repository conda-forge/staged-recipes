#!/usr/bin/env bash
set -eux
mkdir -p "${PREFIX}/bin"
cp ${SRC_DIR}/bin/tlsh* ${PREFIX}/bin
