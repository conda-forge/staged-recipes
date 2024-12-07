set -ex

meson setup build \
    ${MESON_ARGS} \
    --prefix="${PREFIX}" \
    -Dfreetype=enabled \
    -Dexamples=disabled \
    -Dtests=disabled
meson compile -C build -j ${CPU_COUNT}
meson install -C build
