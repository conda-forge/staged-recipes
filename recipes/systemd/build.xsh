#!/usr/bin/env xonsh
$RAISE_SUBPROC_ERROR = True
$XONSH_SHOW_TRACEBACK = False

$CFLAGS += f" -I{$PREFIX}/include/unicode -lrt"
$CFLAGS += " -DO_PATH=010000000"

# copy over missing files
copy_files = {
    "src/basic": [
        "missing_kd.h",
        "missing_in.h",
        "missing_loop.h",
        "missing_time.h",
        "missing_types.h",
        "missing_ioctls.h",
        "missing_inotify.h",
        "missing_neighbour.h",
        "missing_videodev2.h",
        "missing_input-event-codes.h",
    ],
    "src/basic/linux": [
        "sctp.h",
        "if_alg.h",
        "if_vlan.h",
        "securebits.h",
    ],
}
for $dstdir, files in copy_files.items():
    for $f in files:
        cp -v "$RECIPE_DIR/$f" "$SRC_DIR/$dstdir/$f"


mkdir -p build
pushd build
![meson \
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
  --strip \
  ..
]
meson install
meson test
