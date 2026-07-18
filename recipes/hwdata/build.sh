#!/bin/bash

set -euxo pipefail

# `configure` is a hand written script, not autoconf; it only generates
# Makefile.inc. The Makefile refuses to run until that file exists.
./configure \
  --prefix="${PREFIX}" \
  --datadir="${PREFIX}/share"

make install -j"${CPU_COUNT}"
