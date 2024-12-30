#!/usr/bin/env bash

set -xe

./meson.py build --prefix=${PREFIX} -Denable-openblas=true -Denable-pywrapper=true

./ninja -C build install
