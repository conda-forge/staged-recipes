#!/usr/bin/env bash
set -euo pipefail

# -DNDEBUG, added by the compiler activation, breaks the pre-generated lemon parsers.
export CPPFLAGS="${CPPFLAGS//-DNDEBUG/}"
export CFLAGS="${CFLAGS//-DNDEBUG/}"

# The compiler wrappers do not search ${PREFIX}, so point AC_PATH_XTRA at it.
./configure \
  --prefix="${PREFIX}" \
  --x-includes="${PREFIX}/include" \
  --x-libraries="${PREFIX}/lib" \
  --enable-optim=2

make -j"${CPU_COUNT}"

make install
