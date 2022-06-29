#!/usr/bin/env bash

set -e
set -x

if [[ ${OSTYPE} == 'darwin'* ]]; then
  export XML_CATALOG_FILES="${PREFIX}/etc/xml/catalog"
fi

meson setup \
  --prefix ${PREFIX} \
  --libdir ${PREFIX}/lib \
  --buildtype=release \
  c_glib.build c_glib

meson compile -C c_glib.build
meson install -C c_glib.build
