#!/usr/bin/env bash
set -ex

./configure --prefix="${PREFIX}" \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-static     \
            --disable-wall       \
            --without-systemd    \
            --without-systemdsystemunitdir
make -j ${CPU_COUNT}
make install
