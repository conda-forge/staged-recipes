#/usr/bin/env bash

set -e

init_db()
{
    mkdir -p $PREFIX/var
    if [ ! -d $PREFIX/var/db ]; then
      pg_ctl initdb -D $PREFIX/var/db
    fi
}

start_db()
{
    pg_ctl start -D $PREFIX/var/db
    trap "stop_db; exit 0" HUP TERM TSTP
    trap "stop_db; exit 130" INT

    echo -n 'waiting for postgres'
    while [ ! -e /tmp/.s.PGSQL.5432 ]; do
        sleep 1
        echo -n '.'
    done
}

stop_db()
{
    pg_ctl stop -D $PREFIX/var/db || true
    rm -rf $PREFIX/var/db
}


chmod 755 configure
./configure \
    --prefix=$PREFIX \
    --with-pgconfig=$PREFIX/bin/pg_config \
    --with-gdalconfig=$PREFIX/bin/gdal-config \
    --with-xml2config=$PREFIX/bin/xml2-config \
    --with-projdir=$PREFIX \
    --with-libiconv=$PREFIX \
    --with-jsondir=$PREFIX \
    --with-pcredir=$PREFIX \
    --with-gettext \
    --with-raster \
    --with-topology
make

init_db
start_db
make check
stop_db

make install
