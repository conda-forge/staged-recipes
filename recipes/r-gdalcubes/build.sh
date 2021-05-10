#!/bin/bash
export DISABLE_AUTOBREW=1

export LD_LIBRARY_PATH=${PREFIX}/lib/:${LD_LIBRARY_PATH}

export INCLUDE_PATH="${PREFIX}/include":${INCLUDE_PATH}
export C_INCLUDE_PATH="${PREFIX}/include":${C_INCLUDE_PATH}
export CPLUS_INCLUDE_PATH="${PREFIX}/include":${CPLUS_INCLUDE_PATH}
export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib

sed -i.bak 's/${CC} ${CFLAGS} ${PKGCPPFLAGS}/${CC} ${CFLAGS} ${PKGCPPFLAGS} ${LDFLAGS}/g' configure

${R} CMD INSTALL --build . ${R_ARGS}
