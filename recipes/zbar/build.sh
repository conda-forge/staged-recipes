#!/bin/bash

./configure --prefix=$PREFIX  --disable-video --without-gtk --without-python --without-qt --without-imagemagick --without-xv --without-x --without-xshm
make
make check
make install
