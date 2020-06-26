#!/usr/bin/env bash

meson build -Dwith_docs=false -Ddeveloper_build=false --prefix="${PREFIX}" --libdir="${PREFIX}/lib"

ninja -C build

ninja -C build test

ninja -C build install
