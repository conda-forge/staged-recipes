#!/bin/bash

set -euxo pipefail

# Upstream defaults to werror=true, which is not appropriate for a
# distribution build.
#
# libseat-logind defaults to `auto`, which would silently vary with whatever
# happens to be in the host environment, so both backends are pinned
# explicitly. man-pages is disabled to avoid the scdoc build dependency.
meson setup builddir \
  ${MESON_ARGS} \
  --wrap-mode=nodownload \
  -Dwerror=false \
  -Dlibseat-logind=systemd \
  -Dlibseat-seatd=enabled \
  -Dlibseat-builtin=disabled \
  -Dserver=enabled \
  -Dexamples=disabled \
  -Dman-pages=disabled

meson compile -C builddir -j "${CPU_COUNT}" -v
meson install -C builddir
