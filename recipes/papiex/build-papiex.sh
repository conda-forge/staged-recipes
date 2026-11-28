#!/bin/bash
set -euxo pipefail

cd papiex
make -j"${CPU_COUNT}" \
    PREFIX="${PREFIX}" \
    CC="${CC}" \
    AR="${AR}" \
    RANLIB="${RANLIB}" \
    CFLAGS="${CFLAGS}" \
    SHRLDFLAGS="-shared ${LDFLAGS}" \
    MONITOR_INC_PATH="${PREFIX}/include" \
    MONITOR_LIB_PATH="${PREFIX}/lib" \
    PAPI_INC_PATH="${PREFIX}/include" \
    PAPI_LIB_PATH="${PREFIX}/lib" \
    CONFIG_PAPIEX_PAPI=y \
    CONFIG_PAPIEX_DEBUG=n \
    install
install -d "${PREFIX}/include"
install -m 0644 src/papiex.h "${PREFIX}/include/papiex.h"
