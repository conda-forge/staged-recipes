set -ex

meson setup build ${MESON_ARGS} --prefix="${PREFIX}" --buildtype=release
meson compile -C build -j ${CPU_COUNT}
meson install -C build
