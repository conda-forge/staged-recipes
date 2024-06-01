#!/bin/bash
set -e -x

make PREFIX=${PREFIX} install -j${CPU_COUNT}

rm -rf ${PREFIX}/share/man ${PREFIX}/share/doc/${PKG_NAME}
