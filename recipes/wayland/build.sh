set -ex

# Cannot build tests since they rely on assert, which is not available with
# NDEBUG
meson setup build/ \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    -Ddocumentation=false \
    -Ddtd_validation=false \
    -Dtests=false

ninja -j ${CPU_COUNT} -C build/ install
