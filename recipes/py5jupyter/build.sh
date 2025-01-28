#!/usr/bin/env bash
set -ex

$PYTHON -m pip install . -vv
npm pack ${PKG_NAME}@${PKG_VERSION}
mkdir -p ${PREFIX}/share/jupyter/lab/extensions/js
cp ${PKG_NAME}-${PKG_VERSION}.tgz ${PREFIX}/share/jupyter/lab/extensions/js
