#/usr/bin/env bash
set -e

. $RECIPE_DIR/pg.sh


chmod 755 configure
./configure \
    --prefix=$PREFIX \
    --with-pgconfig=$PREFIX/bin/pg_config \
    --with-gdalconfig=$PREFIX/bin/gdal-config \
    --with-xml2config=$PREFIX/bin/xml2-config \
    --with-projdir=$PREFIX \
    --with-libiconv-prefix=$PREFIX \
    --with-libintl-prefix=$PREFIX \
    --with-jsondir=$PREFIX \
    --with-pcredir=$PREFIX \
    --with-gettext \
    --with-raster \
    --with-topology \
    --without-interrupt-tests
make

# There is an issue running shp2pgsql during build time on macOS.
# It seems the side effect is that 26 unit tests fail.
# This is not too bad because we still call shp2pgsql, pgsql2shp 
# and raster2pgsql during the test phase.
if [ $(uname) = "Linux" ]; then
    start_db
    make check
    stop_db
fi

make install
