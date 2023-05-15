#!/usr/bin/env bash

set -ex

meson_config_args=(
    -Dbuildtype=release
    -Dprefix=$PREFIX
    --wrap-mode=nofallback
    -Dtests=false
)

meson setup forgebuild "${meson_config_args[@]}"
meson configure forgebuild

meson compile -v -C forgebuild -j ${CPU_COUNT}
meson install -C forgebuild --no-rebuild
