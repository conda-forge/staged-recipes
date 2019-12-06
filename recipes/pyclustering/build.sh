#!/bin/bash

set -o xtrace -o pipefail -o errexit

BINARY_HOME=${PREFIX}/bin
PACKAGE_HOME=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
export STACK_ROOT=${PACKAGE_HOME}/stackroot
export LIBRARY_PATH=${LIBRARY_PATH}:${PREFIX}/lib

cd ccore/
make ccore_x64

cd ../

PYTHONPATH=`pwd`
export PYTHONPATH=${PYTHONPATH}

$PYTHON setup.py build
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
