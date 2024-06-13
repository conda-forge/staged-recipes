#!/bin/bash

set -euxo pipefail

export MARIADB_CC_INSTALL_DIR=${PREFIX}/bin/mariadb_config
export MARIADB_CC_INCLUDE_DIR=${PREFIX}/include/mariadb
export MARIADB_CC_LIB_DIR=${PREFIX}/lib/mariadb

pushd mariadb
${PYTHON} -m pip install -vv --no-deps --ignore-installed .
popd