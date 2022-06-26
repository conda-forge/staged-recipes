#!/usr/bin/env bash

set -e
set -x

meson setup c_glib.build c_glib --buildtype=release
meson compile -C c_glib.build
meson install --destdir  ${PREFIX} -C c_glib.build
