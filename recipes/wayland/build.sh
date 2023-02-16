set -ex

meson build/ \
    --prefix=PREFIX \
    --disable-documentation \
    --disable-dtd-validation

ninja -j ${CPU_COUNT} -C build/ install
