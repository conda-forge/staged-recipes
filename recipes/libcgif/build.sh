set -ex

meson setup build ${MESON_ARGS} \
    -Dtests=true \
    -Dexamples=true \
    -Dinstall_examples=false

meson compile -C build -j ${CPU_COUNT}
meson test -C build --num-processes ${CPU_COUNT} --print-errorlogs
meson install -C build
