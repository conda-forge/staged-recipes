#!/bin/bash
set -ex

export PATH=${PREFIX}/bin:$PATH
export CC=${CC}
export CXX=${CXX}
export AR=${AR}
export CFLAGS="-I${PREFIX}/include $CFLAGS"
export LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -Wl,-rpath-link,${PREFIX}/lib $LDFLAGS"
export ACLOCAL_PATH="${PREFIX}/share/aclocal:$ACLOCAL_PATH"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"

mkdir -p m4
sed -i '/AC_INIT/a AC_CONFIG_MACRO_DIR([m4])' configure.ac
sed -i '1i ACLOCAL_AMFLAGS = -I m4' Makefile.am
sed -i 's/AC_PROG_CC_STDC/AC_PROG_CC/' configure.ac  # Fixed typo
sed -i "s|/usr/share/cassini-headers/csr_defs.json|${PREFIX}/share/cassini-headers/csr_defs.json|g" utils/cxi_dump_csrs.py
sed -i "s|../cassini-headers/install/share/cassini-headers/csr_defs.json|${PREFIX}/share/cassini-headers/csr_defs.json|g" utils/cxi_dump_csrs.py

autoreconf -ivf
./configure --prefix=${PREFIX} --with-udevrulesdir=${PREFIX}/etc/udev/rules.d
make -j${CPU_COUNT}
make install

# Minimize package size
rm -rf ${PREFIX}/man ${PREFIX}/share/man ${PREFIX}/share/doc ${PREFIX}/share/info
