#! /bin/bash

set -ex

meson setup ${MESON_ARGS} --prefix=$PREFIX build
ninja -C build
ninja -C build install
