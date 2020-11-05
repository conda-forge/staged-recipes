#! /bin/sh

./autogen.sh
./configure \
  --prefix="${PREFIX}" \
  --with-crypto=libgcrypt \
  --disable-static \
  --disable-documentation \
  --disable-python

make -j"${CPU_COUNT}"
make install
# In case we were to split this package, the following would only install libs:
# (But we'd have to consider whether it even makes sense to put libbtrfs
#  alongside libbtrfsutil or if we'd then split into separate packages too.)
#   make install BUILD_PROGRAMS=0
