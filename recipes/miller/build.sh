#!/bin/bash

chmod +x configure

autoreconf -fiv
./configure --disable-maintainer-mode --prefix=$PREFIX

make -j${CPU_COUNT}
make check
make install