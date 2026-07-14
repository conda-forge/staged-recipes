#!/bin/bash
set -euxo pipefail

meson setup builddir \
  --prefix="${PREFIX}" \
  --libdir=lib \
  --buildtype=release \
  --wrap-mode=nofallback

meson compile -C builddir
meson install -C builddir