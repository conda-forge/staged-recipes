#!/bin/bash

set -euxo pipefail

export MARIADB_CC_LIB=${PREFIX}/lib/mariadb
export MARIADB_CC_LIBRARY=${PREFIX}/include/mariadb

export PATH=${MARIADB_CC_LIB}:${MARIADB_CC_LIBRARY}:${PATH}
export MARIADB_CONFIG=${PREFIX}/bin/mariadb_config

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation