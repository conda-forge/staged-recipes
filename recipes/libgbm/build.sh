#!/bin/bash

meson . build  --prefix=${PREFIX} --libdir=lib -Dc_link_args=-ldl
ninja -C build/ install
