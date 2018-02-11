#!/usr/bin/bash

start_db()
{
    mkdir -p $PREFIX/var
    rm -rf $PREFIX/var/db

    pg_ctl initdb -D $PREFIX/var/db
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
