#!/usr/bin/env bash

NOCONFIGURE=1 ./bootstrap.sh
./configure --prefix=${PREFIX} \
  --disable-systemd-daemon \
  --disable-systemd-login \
  --disable-systemd-login \
  --disable-default-build-tests
make -j ${CPU_COUNT}
# tests fail to link on conda-forge CI for some reason,
# though the link and run for me locally. -scopatz
#XFAIL_TESTS="core-util-test thread-mainloop-test channelmap-test" make check
make install
