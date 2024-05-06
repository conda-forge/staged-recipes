#!/bin/bash
set -ex

# Adopt a Unix-friendly path if we're on Windows (see bld.bat).
[ -n "$PATH_OVERRIDE" ] && export PATH="$PATH_OVERRIDE"

make PREFIX=${PREFIX} install -j$CPU_COUNT

rm -rf ${PREFIX}/share/man ${PREFIX}/share/doc/${PKG_NAME}
