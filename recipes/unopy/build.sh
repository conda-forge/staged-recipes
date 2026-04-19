#!/bin/bash

set -eox pipefail

cd "${SRC_DIR}"

$PYTHON -m pip install . -vv --no-deps --no-build-isolation --config-settings=cmake.args="-DBQPD='';-DHIGHS='';-DLAPACK_LIBRARIES='';-DBLAS_LIBRARIES='';-DMETIS_LIBRARY='';-DMUMPS_LIBRARY=''"
