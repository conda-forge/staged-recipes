#!/usr/bin/env bash
set -euo pipefail

# -DNDEBUG, added by the compiler activation, breaks the pre-generated lemon parsers.
export CPPFLAGS="${CPPFLAGS//-DNDEBUG/}"
export CFLAGS="${CFLAGS//-DNDEBUG/}"

# C23, the default in GCC 15, rejects the deliberately unprototyped setfhdr().
export CFLAGS="${CFLAGS} -std=gnu17"

# The compiler wrappers do not search ${PREFIX}, so point AC_PATH_XTRA at it.
./configure \
  --prefix="${PREFIX}" \
  --x-includes="${PREFIX}/include" \
  --x-libraries="${PREFIX}/lib" \
  --enable-optim=2

make -j"${CPU_COUNT}"

make install
