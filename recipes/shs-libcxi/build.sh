#!/bin/bash

set -ex

sed -i "s|../cassini-headers/install/share/cassini-headers/csr_defs.json|${PREFIX}/share/cassini-headers/csr_defs.json|g" utils/cxi_dump_csrs.py

autoreconf -ivf

./configure --prefix=${PREFIX} \
            --with-udevrulesdir=${PREFIX}/etc/udev/rules.d \
	    --enable-static=no

make -j${CPU_COUNT}

make install
