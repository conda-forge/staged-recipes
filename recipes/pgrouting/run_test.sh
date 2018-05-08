#/usr/bin/env bash
set -e

. $RECIPE_DIR/pg.sh


test_create_extension()
{
    extensions="postgis
     pgrouting"

   for extension in $extensions; do 
       psql -d postgres -q -c "CREATE EXTENSION $extension"
   done
}

start_db
test_create_extension
stop_db
