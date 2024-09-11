set -ex

if [[ "${target_platform}" == linux* ]]; then
    MESON_ARGS="${MESON_ARGS} -Dwith_x11=enabled -Dwith_wayland=enabled -Dwith_nvml=enabled"
else
    MESON_ARGS="${MESON_ARGS} -Dwith_x11=disabled -Dwith_wayland=disabled -Dwith_nvml=disabled"
fi

meson setup \
    build \
    ${MESON_ARGS} \
    -Duse_system_spdlog=enabled \
    -Dwith_dbus=disabled \
    -Dinclude_doc=false \
    -Dwith_xnvctrl=disabled \
    -Dmangoplot=disabled \
    -Ddynamic_string_tokens=false

ninja -j${CPU_COUNT} -C build

ninja -C build install
