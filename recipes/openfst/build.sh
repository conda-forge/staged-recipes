#! /usr/bin/env bash

# we need to run autoreconf and automake here because somehow `make` thinks
# that it needs to update the scripts. This answer may be relevant:
# https://stackoverflow.com/a/30386141/1286165
autoreconf
bash ./configure --prefix=${PREFIX} --enable-static=no
automake
make -j ${CPU_COUNT}
make check
make install
