#!/bin/bash
set -ex

autoreconf -ivf
./configure --prefix="${PREFIX}" \
  --disable-static \
  --with-pic