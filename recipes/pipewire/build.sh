#!/bin/bash

set -euxo pipefail

# Minimal PipeWire build: only the core client library (libpipewire-0.3) and
# the SPA plugin API headers (libspa-0.2) are needed so that Weston's
# backend-pipewire can be enabled. Everything that pulls a heavy or unpackaged
# dependency, plus every session manager, example, test, doc and man page, is
# turned off. dbus is kept because it is a genuine core dependency (the
# spa-support dbus plugin), and it is available on conda-forge.
meson setup builddir \
  ${MESON_ARGS} \
  --wrap-mode=nodownload \
  -Dwerror=false \
  -Ddocs=disabled \
  -Dman=disabled \
  -Dexamples=disabled \
  -Dtests=disabled \
  -Dinstalled_tests=disabled \
  -Ddbus=enabled \
  -Dpipewire-alsa=disabled \
  -Dpipewire-jack=disabled \
  -Dpipewire-v4l2=disabled \
  -Djack=disabled \
  -Djack-devel=false \
  -Dalsa=disabled \
  -Dbluez5=disabled \
  -Dgstreamer=disabled \
  -Dgstreamer-device-provider=disabled \
  -Dffmpeg=disabled \
  -Dpw-cat=disabled \
  -Dpw-cat-ffmpeg=disabled \
  -Dv4l2=disabled \
  -Dlibcamera=disabled \
  -Dvulkan=disabled \
  -Dsdl2=disabled \
  -Dsndfile=disabled \
  -Dlibmysofa=disabled \
  -Dlibpulse=disabled \
  -Droc=disabled \
  -Davahi=disabled \
  -Decho-cancel-webrtc=disabled \
  -Dlibusb=disabled \
  -Dopus=disabled \
  -Dfftw=disabled \
  -Debur128=disabled \
  -Dreadline=disabled \
  -Dx11=disabled \
  -Dx11-xfixes=disabled \
  -Dlibcanberra=disabled \
  -Draop=disabled \
  -Dlv2=disabled \
  -Davb=disabled \
  -Dsnap=disabled \
  -Dselinux=disabled \
  -Dlibsystemd=disabled \
  -Dlogind=disabled \
  -Dsystemd-system-service=disabled \
  -Dsystemd-user-service=disabled \
  -Dflatpak=disabled \
  -Dgsettings=disabled \
  -Dgsettings-pulse-schema=disabled \
  -Dlibffado=disabled \
  -Dcompress-offload=disabled \
  -Donnxruntime=disabled \
  -Dudev=disabled \
  -Dsession-managers=[]

meson compile -C builddir -j "${CPU_COUNT}" -v
meson install -C builddir

# Ship dynamic libraries only; drop any libtool archives if present.
rm -f "${PREFIX}"/lib/*.la
