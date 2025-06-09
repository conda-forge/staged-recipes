#!/bin/bash

# Prevent running ldconfig when cross-compiling.
if [[ "${BUILD}" != "${HOST}" ]]; then
  echo "#!/usr/bin/env bash" > ldconfig
  chmod +x ldconfig
  export PATH=${PWD}:$PATH
fi

export CFLAGS="${CFLAGS}"

if [[ $target_platform =~ linux.* ]]; then
    export CFLAGS="${CFLAGS} -DHAVE_PREAD64 -DHAVE_PWRITE64"
fi

if [[ "$target_platform" == "linux-ppc64le" ]]; then
    export PPC64LE="--build=ppc64le-linux"
fi

./configure --prefix=${PREFIX} \
            --build=${BUILD} \
            --host=${HOST} \
            --enable-threadsafe \
            --enable-load-extension \
            --disable-static \
            --with-tclsh="${PREFIX}/bin/tclsh" \
            CFLAGS="${CFLAGS} -I${PREFIX}/include" \
            LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
            ${PPC64LE}

make -j${CPU_COUNT} ${VERBOSE_AT} sqldiff
make -j${CPU_COUNT} ${VERBOSE_AT} sqlite3_rsync
make -j${CPU_COUNT} ${VERBOSE_AT} sqlite3_analyzer

install -m755 sqldiff "${PREFIX}/bin/sqldiff"
install -m755 sqlite3_rsync "${PREFIX}/bin/sqlite3_rsync"
install -m755 sqlite3_analyzer "${PREFIX}/bin/sqlite3_analyze"
