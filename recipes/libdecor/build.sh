set -ex

meson setup build \
    ${MESON_ARGS} \
    --prefix="${PREFIX}" \
    -Ddemo=false
meson compile -C build -j ${CPU_COUNT}
meson install -C build
