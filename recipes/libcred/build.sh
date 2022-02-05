meson setup builddir --buildtype=release --prefix=${PREFIX} -Dlibdir=lib ${MESON_ARGS}
cd builddir
ninja
ninja install