#!/bin/bash

set -euxo pipefail

export PATH="${PREFIX}/include/mariadb:${PREFIX}/lib/mariadb:$PATH"
export MARIADB_CONFIG=${PREFIX}/bin/mariadb_config

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation