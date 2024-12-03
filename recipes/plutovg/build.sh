set -ex

# https://github.com/conda-forge/pulseaudio-feedstock/blob/9509bd27bf712e7652e29e02722f5d73152f235a/recipe/build-client.sh#L21
meson setup build ${MESON_ARGS} --prefix="${PREFIX}" --buildtype=release
meson compile -C build -j ${CPU_COUNT}
meson install -C build
