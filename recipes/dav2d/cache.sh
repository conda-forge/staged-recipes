set -ex

meson setup builddir          \
    ${MESON_ARGS}             \
    -Denable_tests=false

meson compile -C builddir

meson install -C builddir --no-rebuild --strip
