#!/usr/bin/env bash

set -xe

./meson.py build --prefix=${PREFIX} -Denable-openblas=true

./ninja -C build install
