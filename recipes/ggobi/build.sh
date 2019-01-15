#!/bin/bash
./configure --with-all-plugins --prefix=${PREFIX}
make
make install
make ggobirc
mkdir -p ${PREFIX}/etc/xdg/ggobi
cp ggobirc ${PREFIX}/etc/xdg/ggobi/ggobirc
