#!/bin/bash

set -euxo pipefail

# ${MESON_ARGS} carries --prefix, -Dlibdir=lib, -Dbuildtype=release and, when
# cross compiling, --cross-file. -Dlibdir=lib matters here: meson would
# otherwise guess lib64 on the AlmaLinux build image and emit a libinput.pc
# pointing at a directory conda does not use.
#
# lua-plugins is `auto`, so it is pinned explicitly to keep the build from
# silently gaining a lua dependency if lua ever appears in the host env.
meson setup builddir \
  ${MESON_ARGS} \
  --wrap-mode=nodownload \
  -Ddocumentation=false \
  -Dtests=false \
  -Ddebug-gui=false \
  -Dlibwacom=false \
  -Dinstall-tests=false \
  -Dlua-plugins=disabled \
  -Dudev-dir="${PREFIX}/lib/udev" \
  -Dzshcompletiondir=no

meson compile -C builddir -j "${CPU_COUNT}" -v
meson install -C builddir
