#!/bin/bash
# xschem build for conda-forge (linux-64 / linux-aarch64).
#
# Two conda-forge specifics handled here:
#  - xschem's build system is scconfig, which ignores the environment
#    CFLAGS/LDFLAGS: they must be passed as configure args (autoconf-style
#    KEY=VALUE is supported).
#  - conda-forge's xorg-libx11 does not ship the X protocol headers
#    (X11/X.h, ...); those come from xorg-xorgproto (a host requirement).
set -ex

# Resolve PREFIX to an absolute path: scconfig cd's into its own subdirectory
# during detection, so only an absolute -I/-L is guaranteed to resolve there.
PFXABS=$(readlink -f "$PREFIX")

./configure --prefix="${PREFIX}" \
  CC="$CC" \
  CFLAGS="$CFLAGS -I${PFXABS}/include" \
  LDFLAGS="$LDFLAGS -L${PFXABS}/lib"

make -j${CPU_COUNT:-4} V=1
make -j${CPU_COUNT:-4} install
