#!/usr/bin/env bash
set -ex

mkdir -p build
cd build

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DICAL_BUILD_DOCS=false \
      -DGOBJECT_INTROSPECTION=True \
      ..
make
make ARGS="-E .*libical-glib.*" test
make install
