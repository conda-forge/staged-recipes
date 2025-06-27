#!/bin/bash

set -euxo pipefail

# Prevent running ldconfig when cross-compiling.
if [[ "${BUILD}" != "${HOST}" ]]; then
  echo "#!/usr/bin/env bash" > ldconfig
  chmod +x ldconfig
  export PATH=${PWD}:$PATH
fi

export OPTIONS="${OPTIONS:-}"

if [[ $target_platform =~ linux.* ]]; then
    export CFLAGS="${CFLAGS} -DHAVE_PREAD64 -DHAVE_PWRITE64"
fi

if [[ "$target_platform" == "linux-ppc64le" ]]; then
    export PPC64LE="--build=ppc64le-linux"
else
    export PPC64LE=""
fi

./configure --prefix=${PREFIX} \
            --build=${BUILD} \
            --host=${HOST} \
            --enable-threadsafe \
            --enable-load-extension \
            --disable-static \
            --dynlink-tools \
            --with-tclsh="${PREFIX}/bin/tclsh" \
            CFLAGS="${CFLAGS} ${OPTIONS} -I${PREFIX}/include" \
            LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
            ${PPC64LE}

make -j${CPU_COUNT} sqldiff
install -m755 sqldiff "${PREFIX}/bin/sqldiff"

make -j${CPU_COUNT} sqlite3_rsync
install -m755 sqlite3_rsync "${PREFIX}/bin/sqlite3_rsync"

make -j${CPU_COUNT} sqlite3_analyzer
install -m755 sqlite3_analyzer "${PREFIX}/bin/sqlite3_analyze"
