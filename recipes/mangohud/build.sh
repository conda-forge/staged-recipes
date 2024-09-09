set -ex

if [[ "${target_platform}" == linux* ]]; then
    MESON_ARGS="${MESON_ARGS} -Dwith_x11=enabled -Dwith_wayland=enabled -Dwith_dbus=enabled"
fi

meson build ${MESON_ARGS} \
    -Duse_system_spdlog=enabled \
    -Dinclude_doc=false \
    -Dwith_nvml=disabled \
    -Dwith_xnvctrl=disabled \
    -Dmangoplot=disabled \
    -Ddynamic_string_tokens=false

ninja -j${CPU_COUNT} -C build

ninja -C build install
