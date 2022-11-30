#!/bin/bash
mkdir build
cd build
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX= ..
make
make DESTDIR="$PREFIX" install
ln -s ../libexec/vncserver "$PREFIX/bin/vncserver"
