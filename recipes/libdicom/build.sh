#!/usr/bin/env bash

meson setup ${MESON_ARGS} builddir
meson compile -j${CPU_COUNT} -C builddir

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]
then
    meson test -C builddir
fi

meson install -C builddir
