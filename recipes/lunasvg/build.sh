set -ex

meson setup build ${MESON_ARGS} --prefix="${PREFIX}"
meson compile -C build -j ${CPU_COUNT}
meson install -C build
