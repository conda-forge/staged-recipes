#!/bin/sh

set -x -e
set -o pipefail

mkdir -p ${PREFIX}/bin
cp -r ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION} ${PREFIX}
ln -s ${PREFIX}/${PKG_NAME}-${PKG_VERSION}/bin/${PKG_NAME} ${PREFIX}/bin/${PKG_NAME}
