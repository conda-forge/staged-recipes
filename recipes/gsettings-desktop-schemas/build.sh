set -ex
meson setup builddir \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib

meson compile -C builddir

meson install -C builddir
