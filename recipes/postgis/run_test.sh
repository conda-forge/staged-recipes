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
    pg_ctl stop -D $PREFIX/var/db
}

test_create_extension()
{
    extensions="postgis
     fuzzystrmatch
     address_standardizer
     address_standardizer_data_us
     postgis_tiger_geocoder
     postgis_topology"

   for extension in $extensions; do 
       psql -d postgres -q -c "CREATE EXTENSION $extension"
   done
}

init_db
start_db
test_create_extension
stop_db
