#!/bin/bash

chmod +x configure

autoreconf -fiv
./configure --disable-maintainer-mode --prefix=$PREFIX
make
make check
make install