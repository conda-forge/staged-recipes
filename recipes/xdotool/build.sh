#!/bin/bash
set -ex

make PREFIX=${PREFIX} install -j$CPU_COUNT

rm -rf ${PREFIX}/share/man ${PREFIX}/share/doc/${PKG_NAME}
