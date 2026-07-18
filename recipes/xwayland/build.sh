#!/bin/bash

set -euxo pipefail

# Xwayland runs wayland-scanner for its protocol bindings, and meson resolves
# it for the build machine. The .pc file points at a binary inside its own
# prefix, so a host-prefix hit would hand meson a target-architecture binary.
# Meson reads the *_FOR_BUILD variables for the build machine, so point them at
# $BUILD_PREFIX, where the `wayland` build dependency lives.
export PKG_CONFIG_PATH_FOR_BUILD="${BUILD_PREFIX}/lib/pkgconfig:${BUILD_PREFIX}/share/pkgconfig"

# This tarball is Xwayland-only, so there are no -Dxorg/-Dxnest/-Dxephyr
# options to turn off (passing them is a hard error). Xvfb is the exception:
# it defaults to true and belongs to the xorg-server, not here.
#
# Disabled features and why:
#   glx          needs dri.pc / dri_interface.h, which no conda-forge package
#                ships since modern mesa dropped them. X11 clients under
#                Xwayland therefore fall back to software GL.
#   secure-rpc   would need libtirpc; SUN-DES-1 auth is useless for Xwayland
#   xdmcp        Xwayland is not an XDMCP display
#   xwayland_ei  libei is not packaged on conda-forge
#
# xkb_dir/xkb_bin_dir are left at their defaults: xkbcomp.pc already exports
# xkbconfigdir and bindir inside $PREFIX, and meson.build prefers those.
meson setup builddir \
  ${MESON_ARGS} \
  --wrap-mode=nodownload \
  -Dxvfb=false \
  -Dglamor=true \
  -Ddri3=true \
  -Dglx=false \
  -Dsecure-rpc=false \
  -Dxdmcp=false \
  -Dxdm-auth-1=false \
  -Dxwayland_ei=false \
  -Dlibunwind=false \
  -Dsha1=libnettle \
  -Ddocs=false \
  -Ddevel-docs=false

meson compile -C builddir -j "${CPU_COUNT}" -v
meson install -C builddir
