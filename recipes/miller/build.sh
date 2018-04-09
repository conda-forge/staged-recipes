#!/bin/bash

chmod +x configure

autoreconf -fiv
./configure --disable-multilib  --prefix=$PREFIX
make
make check
make install