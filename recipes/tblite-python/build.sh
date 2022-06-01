#!/usr/bin/env bash

set -ex

meson setup \
  _build python \
  ${MESON_ARGS:---prefix=${PREFIX} --libdir=lib} \
  --buildtype=release -Dpython_version=${PYTHON} \
  || cat _build/meson-logs/meson-log.txt
meson compile -C _build
meson install -C _build --no-rebuild
