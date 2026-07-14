#!/bin/bash
set -euxo pipefail

meson setup builddir \
  --prefix="${PREFIX}" \
  --buildtype=release \
  --wrap-mode=nofallback

meson compile -C builddir
meson install -C builddir