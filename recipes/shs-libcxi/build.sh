#!/bin/bash

set -ex

sed -i '/AC_INIT/a AC_CONFIG_MACRO_DIR([m4])' configure.ac
sed -i '1i ACLOCAL_AMFLAGS = -I m4' Makefile.am
sed -i 's/AC_PROG_CC_STDC/AC_PROG_CC/' configure.ac
sed -i "s|/usr/share/cassini-headers/csr_defs.json|${PREFIX}/share/cassini-headers/csr_defs.json|g" utils/cxi_dump_csrs.py
sed -i "s|../cassini-headers/install/share/cassini-headers/csr_defs.json|${PREFIX}/share/cassini-headers/csr_defs.json|g" utils/cxi_dump_csrs.py

autoreconf -ivf

./configure --prefix=${PREFIX} \
            --with-udevrulesdir=${PREFIX}/etc/udev/rules.d

make -j${CPU_COUNT}

make install
