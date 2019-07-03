#!/usr/bin/env bash
set -ex

mkdir -p build
cd build

if [ "$(uname)" == "Darwin" ]; then
  use_goi="False"
else
  use_goi="True"
fi

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
      -DCMAKE_BUILD_TYPE=Release \
      -DICAL_BUILD_DOCS=false \
      -DGOBJECT_INTROSPECTION=${use_goi} \
      ..
make
make ARGS="-E .*libical-glib.*" test
make install
