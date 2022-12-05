#!/bin/bash
set -ex

make
make install

initdb -D test_db
pg_ctl -D test_db -l test.log start

make installcheck

pg_ctl -D test_db stop

