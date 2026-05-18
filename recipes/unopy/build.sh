#!/bin/bash

set -eox pipefail

cd "${SRC_DIR}"

$PYTHON -m pip install . -vv \
    --no-deps \
    --no-build-isolation \
    --config-settings=cmake.args="-DBQPD='';-DHIGHS='';-DMETIS_LIBRARY='';-DMUMPS_LIBRARY='';-DBLAS_LIBRARIES=${PREFIX}/lib/libblas.so;-DLAPACK_LIBRARIES=${PREFIX}/lib/liblapack.so"
