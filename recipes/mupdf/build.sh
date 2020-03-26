#!/usr/bin/env bash
set -ex

# build system uses non-standard env vars
uname=$(uname)
if [[ "$uname" == "Darwin" ]]; then
  export CFLAGS="${CFLAGS} -I ${PREFIX}/include/harfbuzz"
  export CFLAGS="${CFLAGS} -I ${PREFIX}/include/freetype2"
fi
export XCFLAGS="${CFLAGS}"
export XLIBS="${LIBS}"
export USE_SYSTEM_LIBS=yes
export USE_SYSTEM_JPEGXR=yes

# build and install
make prefix="${PREFIX}" -j ${CPU_COUNT} all
# no make check
make prefix="${PREFIX}" install
