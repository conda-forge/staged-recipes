#!/bin/bash

set -euxo pipefail

export MARIADB_CC_INSTALL_DIR=${PREFIX}/bin/mariadb_config
export MARIADB_CC_INCLUDE_DIR=${PREFIX}/include/mariadb
export MARIADB_CC_LIB_DIR=${PREFIX}/lib/mariadb
export MARIADB_CONFIG=${PREFIX}/bin/mariadb_config

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation