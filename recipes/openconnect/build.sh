#!/bin/bash
set -x

mkdir -p ${PREFIX}/etc/openconnect
cp vpnc-scripts/vpnc-script ${PREFIX}/etc/openconnect/vpnc-script

./configure \
    --prefix=${PREFIX} \
    --sbindir=${PREFIX}/bin \
    --localstatedir=${PREFIX}/var \
    --with-vpnc-script=${PREFIX}/etc/openconnect/vpnc-script \
##

make -j${CPU_COUNT}
make check
make install
