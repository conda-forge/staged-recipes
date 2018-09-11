#! /bin/bash

if [ $(uname) == Darwin ]; then
  export GRASS_PYTHON=$(which pythonw)
else
  export GRASS_PYTHON=$(which python)
  export LD_LIBRARY_PATH=$PREFIX/lib
fi

CONFIGURE_FLAGS="\
  --prefix=$PREFIX \
  --with-freetype \
  --with-freetype-includes=$PREFIX/include/freetype2 \
  --with-freetype-libs=$PREFIX/lib \
  --with-gdal=$PREFIX/bin/gdal-config \
  --with-gdal-libs=$PREFIX/lib \
  --with-proj=$PREFIX/bin/proj \
  --with-proj-includes=$PREFIX/include \
  --with-proj-libs=$PREFIX/lib \
  --with-proj-share=$PREFIX/share/proj \
  --with-geos=$PREFIX/bin/geos-config \
  --with-jpeg-includes=$PREFIX/include \
  --with-jpeg-libs=/$PREFIX/lib \
  --with-png-includes=$PREFIX/include \
  --with-png-libs=$PREFIX/lib \
  --with-tiff-includes=$PREFIX/include \
  --with-tiff-libs=$PREFIX/lib \
  --without-postgres \
  --without-mysql \
  --with-sqlite \
  --with-sqlite-libs=$PREFIX/lib \
  --with-sqlite-includes=$PREFIX/include \
  --with-fftw-includes=$PREFIX/include \
  --with-fftw-libs=$PREFIX/lib \
  --with-cxx \
  --with-cairo \
  --with-cairo-includes=$PREFIX/include/cairo \
  --with-cairo-libs=$PREFIX/lib \
  --with-cairo-ldflags="-lcairo" \
  --without-readline \
  --enable-64bit \
  --with-libs=$PREFIX/lib \
  --with-includes=$PREFIX/include \
"

if [ $(uname) == Darwin ]; then
  CONFIGURE_FLAGS="\
    $CONFIGURE_FLAGS \
    --with-opengl=aqua \
    "
fi

./configure $CONFIGURE_FLAGS
# The make step produces so much output that it causes Travis to think
# that something went wrong and cancels the build.
make -j4 GDAL_DYNAMIC= > out.txt 2>&1 || (tail -400 out.txt && echo "ERROR in make step" && exit -1)
make -j4 install
