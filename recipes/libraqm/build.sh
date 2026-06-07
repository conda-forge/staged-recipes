#!/bin/bash
set -ex

meson setup builddir ${MESON_ARGS} --backend=ninja
meson compile -v -C builddir
meson test -C builddir --print-errorlog
meson install -C builddir
