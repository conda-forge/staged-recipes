#!/bin/bash

export LC_ALL=C
export NINJA=$(which ninja)
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"

# Commented:     # -Djavascript=enabled \     # -Dlua=luajit \     # -Duchardet=enabled \     # --mandir=${PREFIX}/share/man \

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

# if [ "$(uname)" == "Darwin" ]; then
#     libarchive=${PREFIX}
#     inreplace "${PREFIX}/lib/pkgconfig/mpv.pc" \
#         '^Requires.private:(.*)\blibarchive\b(.*?)(,.*)?$' \
#         "Requires.private:\\1${libarchive}/lib/pkgconfig/libarchive.pc\\3"
# fi

cp etc/mpv.bash-completion "${PREFIX}/share/bash-completion/completions/mpv"
cp etc/_mpv.zsh "${PREFIX}/share/zsh/site-functions/_mpv"
