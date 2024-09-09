set -ex

meson build ${MESON_ARGS} -Dwith_xnvctrl=disabled
ninja -j${CPU_COUNT} -C build

ninja -C build install
