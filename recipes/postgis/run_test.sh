#/usr/bin/env bash
set -e

. $RECIPE_DIR/pg.sh


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

start_db
test_create_extension
stop_db
