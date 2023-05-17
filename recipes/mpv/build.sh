#!/bin/bash

export LC_ALL=C
export NINJA=$(which ninja)
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"

meson setup build \
    -Dhtml-build=enabled \
    -Dlibmpv=true \
    -Dlibarchive=enabled \
    --sysconfdir=${PREFIX}/etc \
    --datadir=${PREFIX}/share \
    --prefix=${PREFIX} \
    ${MESON_ARGS}

meson compile -C build --verbose
meson install -C build

cp etc/mpv.bash-completion "${PREFIX}/share/bash-completion/completions/mpv"
cp etc/_mpv.zsh "${PREFIX}/share/zsh/site-functions/_mpv"
