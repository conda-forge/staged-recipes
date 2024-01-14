#!/bin/bash

export LC_ALL=C
export NINJA=$(which ninja)
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"

if [[ "${target_platform}" == osx-* ]]; then
  # iconv.pc is not shipped, see https://github.com/Homebrew/homebrew-core/issues/117869
  # and https://github.com/conda-forge/libiconv-feedstock/issues/36
  sed -i '' '/Requires.private: iconv/d' ${PREFIX}/lib/pkgconfig/libarchive.pc
fi

meson setup build \
    -Dhtml-build=enabled \
    -Dlibmpv=true \
    -Dlibarchive=enabled \
    -Dzimg=disabled \
    --sysconfdir=${PREFIX}/etc \
    --datadir=${PREFIX}/share \
    --prefix=${PREFIX} \
    ${MESON_ARGS}

meson compile -C build --verbose
meson install -C build

cp etc/mpv.bash-completion "${PREFIX}/share/bash-completion/completions/mpv"
cp etc/_mpv.zsh "${PREFIX}/share/zsh/site-functions/_mpv"
