#!/bin/bash

set -euxo pipefail

# ${MESON_ARGS} comes from the compiler activation and already carries
# --prefix, -Dlibdir=lib, -Dbuildtype=release, and --cross-file when cross
# compiling, so it must be passed through verbatim.
meson setup builddir \
  ${MESON_ARGS} \
  --wrap-mode=nodownload \
  -Dexamples=false

meson compile -C builddir -j "${CPU_COUNT}" -v
meson install -C builddir
