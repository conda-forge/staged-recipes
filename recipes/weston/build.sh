#!/bin/bash

set -euxo pipefail

# protocol/meson.build does `dependency('wayland-scanner', native: true)` and
# then runs the binary named by the .pc file's wayland_scanner variable. That
# variable resolves inside the prefix the .pc file came from, so a host-prefix
# hit would hand meson a target-architecture binary that cannot execute on the
# build machine. Meson reads the *_FOR_BUILD variables for the build machine,
# so point them at $BUILD_PREFIX, where the `wayland` build dependency lives.
export PKG_CONFIG_PATH_FOR_BUILD="${BUILD_PREFIX}/lib/pkgconfig:${BUILD_PREFIX}/share/pkgconfig"

# The vulkan renderer compiles its GLSL shaders to SPIR-V at build time with
# glslangValidator, which meson resolves from PATH and runs on the build
# machine, so glslang is a build (not host) dependency.

# Disabled features and why:
#   deprecated-remoting  upstream-deprecated gstreamer remoting plugin,
#                        superseded by the pipewire backend
#   deprecated-pipewire  upstream-deprecated pipewire plugin, superseded by
#                        the pipewire backend
#   (nothing else: every backend, both renderers and every shell are enabled)
# --wrap-mode=nodownload keeps meson from fetching the bundled aml, neatvnc,
# display-info and perfetto subprojects over the network.
meson setup builddir \
  ${MESON_ARGS} \
  --wrap-mode=nodownload \
  -Dbackend-drm=true \
  -Dbackend-headless=true \
  -Dbackend-wayland=true \
  -Dbackend-x11=true \
  -Dbackend-rdp=true \
  -Dbackend-vnc=true \
  -Dbackend-pipewire=true \
  -Dbackend-default=drm \
  -Drenderer-gl=true \
  -Drenderer-vulkan=true \
  -Dxwayland=true \
  -Dxwayland-path="${PREFIX}/bin/Xwayland" \
  -Dsystemd=true \
  -Dshell-desktop=true \
  -Dshell-ivi=true \
  -Dshell-kiosk=true \
  -Dshell-lua=true \
  -Dcolor-management-lcms=true \
  -Dimage-jpeg=true \
  -Dimage-webp=true \
  -Ddemo-clients=true \
  -Dsimple-clients=all \
  -Dtools=calibrator,debug,info,terminal,touch-calibrator \
  -Ddeprecated-remoting=false \
  -Ddeprecated-pipewire=false \
  -Dtests=false \
  -Dtest-junit-xml=false \
  -Ddoc=false

meson compile -C builddir -j "${CPU_COUNT}" -v
meson install -C builddir
