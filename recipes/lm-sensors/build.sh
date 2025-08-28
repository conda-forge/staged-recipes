#!/bin/bash
set -ex

make install \
    PREFIX="${PREFIX}" \
    ETCDIR="${PREFIX}/etc" \
    CC="${CC}" \
    AR="${AR}" \
    CFLAGS="${CFLAGS}" \
    USER_LDFLAGS="${LDFLAGS}" \
    LIBICONV="-L${PREFIX}/lib -liconv"

# Minimize package size: remove docs, man pages, etc.
rm -rf ${PREFIX}/man ${PREFIX}/share/man ${PREFIX}/share/doc ${PREFIX}/share/info

# Install license files
mkdir -p ${PREFIX}/share/licenses/${PKG_NAME}
cp COPYING ${PREFIX}/share/licenses/${PKG_NAME}/COPYING
cp COPYING.LGPL ${PREFIX}/share/licenses/${PKG_NAME}/COPYING.LGPL
