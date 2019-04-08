#!/usr/bin/env bash

set -x
set -e

autoreconf -vif
./configure --prefix=${PREFIX}
make install