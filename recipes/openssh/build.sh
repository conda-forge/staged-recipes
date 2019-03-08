#!/bin/bash
if [[ "$target_platform" == "linux-64" ]]; then
  export LDFLAGS="-Wl,-rpath=$PREFIX/lib"
fi
./configure \
  --with-libedit \
  --prefix=$PREFIX \
  --with-zlib=$PREFIX \
  --with-ssl-dir=$PREFIX \
  --with-kerberos5=$PREFIX \
  --sbindir=$PREFIX/bin
make -j$CPU_COUNT
make install
