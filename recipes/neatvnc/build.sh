#!/bin/bash

set -euxo pipefail

# ${MESON_ARGS} comes from the compiler activation and already carries
# --prefix, -Dlibdir=lib, -Dbuildtype=release, and --cross-file when cross
# compiling, so it must be passed through verbatim.
#
# Enabled features for a fully featured VNC backend:
#   tls     -> gnutls: VeNCrypt encryption and authentication
#   nettle  -> RSA-AES / DES / Apple-DH authentication and WebSocket transport
# zlib and pixman are always required; libdrm headers are always pulled for
# dmabuf pixel formats. jpeg, gbm and h264 are disabled: they are not needed by
# Weston's VNC backend and would drag in turbojpeg/mesa/ffmpeg.
meson setup builddir \
  ${MESON_ARGS} \
  --wrap-mode=nodownload \
  -Dtls=enabled \
  -Dnettle=enabled \
  -Djpeg=disabled \
  -Dgbm=disabled \
  -Dh264=disabled \
  -Dtests=false \
  -Dexamples=false \
  -Dbenchmarks=false

meson compile -C builddir -j "${CPU_COUNT}" -v
meson install -C builddir
