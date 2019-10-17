#!/usr/bin/env bash
set -ex

export CFLAGS="${CFLAGS} -I${PREFIX}/include/unicode -lrt"
export SYSTEMD_UNIT_PATH=""

# copy over missing files
basic_files="
  missing_kd.h
  missing_in.h
  missing_loop.h
  missing_time.h
  missing_types.h
  missing_ioctls.h
  missing_inotify.h
  missing_neighbour.h
  missing_videodev2.h
  missing_input-event-codes.h
"
for f in $basic_files
do
  cp -v "$RECIPE_DIR/$f" "$SRC_DIR/src/basic/$f"
done

linux_files="
  sctp.h
  if_alg.h
  if_vlan.h
  securebits.h
"
for f in $linux_files
do
  cp -v "$RECIPE_DIR/$f" "$SRC_DIR/src/basic/linux/$f"
done

# patch the meson "minstall.py" file so that we avoid trying to install
# to the system root with polkit's pkexec. Ignore such files instead
bldprefix="$(dirname $(dirname $(which meson)))"
sitepkgs="$(echo -n ${bldprefix}/lib/python3.*/site-packages)"
patch "${sitepkgs}/mesonbuild/minstall.py" "${RECIPE_DIR}/minstall.py.patch"

# finally, build it!
mkdir -p build
pushd build
meson \
  --prefix=$PREFIX \
  --libdir=$PREFIX/lib \
  --buildtype=release \
  -Ddefault-dnssec=no \
  -Dblkid=true         \
  -Ddefault-dnssec=no   \
  -Dfirstboot=false      \
  -Dinstall-tests=false        \
  -Dldconfig=false             \
  -Dsplit-usr=true             \
  -Dsysusers=false             \
  -Drpmmacrosdir=no            \
  -Dsmack=false \
  -Dseccomp=false \
  -Dselinux=false \
  -Defi=false \
  -Dportabled=false \
  -Dlogind=false \
  -Dlibidn2=false \
  -Dtests=false \
  -Dremote=false \
  -Drfkill=false \
  -Dpolkit=false \
  -DSysV=false \
  -Dgshadow=false \
  -Dpam=false \
  -Dadm-group=false \
  -Dwheel-group=false \
  -Drootprefix=$PREFIX \
  -Drootlibdir=$PREFIX/lib \
  -Ddbuspolicydir=$PREFIX/share/xml/dbus-1 \
  -Dcertificate-root=$PREFIX/ssl \
  --strip \
  ..
ninja
ninja -v install
