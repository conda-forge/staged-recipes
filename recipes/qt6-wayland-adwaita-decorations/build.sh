#!/bin/bash
set -ex

# The Adwaita client-side decoration plugin lives in the qtwayland module, but
# it is the only part of that module we want here. As of Qt 6.11 the Wayland
# *client* itself was merged into qtbase, and this decoration was left behind
# in qtwayland only because it links against QtSvg, which qtbase is not allowed
# to depend on:
#   https://github.com/qt/qtwayland/blob/v6.11.1/src/client/configure.cmake
#
# Building it standalone, rather than turning on
# FEATURE_wayland_decoration_adwaita in qt6-main, means qt6-main does not have
# to build the whole qtwayland module (which would also drag in the Wayland
# compositor). This mirrors what the qt-gtk-platformtheme feedstock does for
# the GTK3 platform theme.
#
# This is the upstreamed version of https://github.com/FedoraQt/QAdwaitaDecorations

cp -R src/plugins/decorations/adwaita/ adwaita_decoration
cd adwaita_decoration
cp "${RECIPE_DIR}/adwaita_decoration_CMakeLists.txt" CMakeLists.txt

QT_HOST_PATH="${PREFIX}"
if [[ "${build_platform}" != "${target_platform}" ]]; then
    QT_HOST_PATH="${BUILD_PREFIX}"
fi

cmake ${CMAKE_ARGS} -G Ninja \
    -B build -S . \
    -DQT_HOST_PATH="${QT_HOST_PATH}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DQT_PLUGINS_DIR="${PREFIX}/lib/qt6/plugins"

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
