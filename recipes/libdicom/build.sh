#!/usr/bin/env bash

meson setup --buildtype="release" --prefix="${PREFIX}" builddir
meson compile -j${CPU_COUNT} -C builddir

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]
then
    meson test -C builddir
fi

meson install -C builddir
