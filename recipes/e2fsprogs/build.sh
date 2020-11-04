#! /bin/sh

autoreconf -fis -I "${PREFIX}/share/aclocal"
AWK=awk \
  ./configure \
  --prefix="${PREFIX}" \
  --sbindir='${exec_prefix}/bin' \
  --enable-elf-shlibs \
  --disable-fsck \
  --disable-uuidd \
  --disable-libuuid \
  --disable-libblkid

make -j$CPU_COUNT
