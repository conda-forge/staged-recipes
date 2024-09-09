set -ex

meson build -Dwith_xnvctrl=disabled
ninja -j${CPU_COUNT} -C build

ninja -C build install
