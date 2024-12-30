#!/usr/bin/env bash

set -xe

git status

./meson.py build --prefix=${PREFIX} -Denable-openblas=true -Denable-pywrapper=true -Denable-autodiff=true -Denable-directdiff=true

./ninja -C build install
