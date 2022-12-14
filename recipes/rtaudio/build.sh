#!/bin/bash

set -ex

meson_config_args=(
  --prefix="$PREFIX"
  --wrap-mode=nofallback
  --buildtype=release
  --backend=ninja
  --default-library=shared
  -Dlibdir=lib
  -Ddocs=false
)

if [[ $target_platform == linux* ]] ; then
    meson_config_args+=(
        -Dalsa=enabled
        -Djack=enabled
        -Dpulse=enabled
    )
elif [[ $target_platform == oss* ]] ; then
    meson_config_args+=(
        -Dcore=enabled
    )
fi

meson setup builddir ${MESON_ARGS} "${meson_config_args[@]}"
meson compile -v -C builddir -j ${CPU_COUNT}
meson install -C builddir
