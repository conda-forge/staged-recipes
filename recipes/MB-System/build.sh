#! /bin/bash

./configure --prefix=${PREFIX} \
  --with-gdal-config=${PREFIX}/bin --disable-mbtools \
  --with-motif-lib=${PREFIX}/lib/ \
  --with-motif-include=${PREFIX}/include \
  --with-fftw-lib=${PREFIX}/lib/  \
  --with-fftw-include=${PREFIX}/include \
  --with-opengl-lib=/${PREFIX}/lib \
  --with-opengl-include=${PREFIX}/include
  --with-proj-lib=${PREFIX}/lib/ \
  --with-proj-include=${PREFIX}/include

make -j${CPU_COUNT}
make -j${CPU_COUNT} install
