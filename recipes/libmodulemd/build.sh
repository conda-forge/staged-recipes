#!/usr/bin/env bash

meson build -Dwith_docs=false -Ddeveloper_build=false --prefix="${PREFIX}" --libdir="${PREFIX}/lib"

ninja -C build

# test_import_headers is broken with conda due to hard coding gcc
# meson doesn't provide a good way for disabling individual tests so just skip running them all for now
# https://github.com/mesonbuild/meson/issues/6999
# ninja -C build test

ninja -C build install
