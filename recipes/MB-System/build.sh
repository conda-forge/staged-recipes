#! /bin/bash

./configure --with-gdal-config=$PREFIX/bin --disable-mbtools \
  --with-motif-lib=$PREFIX/lib/ \
  --with-motif-include=$PREFIX/include \
  --with-fftw-lib=$PREFIX/lib/  \
  --with-fftw-include=$PREFIX/include \
  --with-proj-lib=$PREFIX/lib/ \
  --with-proj-include=$PREFIX/include \
  --prefix=$PREFIX \
  --with-opengl-lib=/$PREFIX/lib \
  --with-opengl-include=$PREFIX/include

make -j4
make -j4 install
