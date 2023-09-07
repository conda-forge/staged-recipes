set -ex

meson setup builddir          \
    ${MESON_ARGS}             \
    -Denable_tests=false      \
    --buildtype=release

meson compile -C builddir

meson install -C builddir --no-rebuild
