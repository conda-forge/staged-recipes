#!/bin/bash

chmod +x configure

./configure --disable-maintainer-mode --prefix=$PREFIX --with-oniguruma=$PREFIX

make -j${CPU_COUNT}
make check
make install
