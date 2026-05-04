#!/bin/bash
set -e

echo "Setting up PostgreSQL test database..."

# Create a temporary directory for the database
export PGDATA=$(mktemp -d)
export PGHOST=$PGDATA
export PGUSER="postgres"
export PGDATABASE=test_osm2pgsql

echo "Initializing PostgreSQL database in $PGDATA"
initdb -D "$PGDATA" --auth=trust --no-locale --encoding=UTF8 --username="$PGUSER"

# Start PostgreSQL in the background
echo "Starting PostgreSQL server..."
pg_ctl -D "$PGDATA" -l "$PGDATA/logfile" -o "-k $PGDATA -h ''" start

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if pg_isready -h "$PGDATA" > /dev/null 2>&1; then
        echo "PostgreSQL is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "PostgreSQL failed to start in time"
        cat "$PGDATA/logfile"
        exit 1
    fi
    sleep 1
done

# Create test database
echo "Creating test database..."
createdb -h "$PGDATA" -U "$PGUSER" "$PGDATABASE"

# Enable PostGIS extension
echo "Enabling PostGIS extension..."
psql -h "$PGDATA" -U "$PGUSER" -d "$PGDATABASE" -c "CREATE EXTENSION postgis;"

# Enable hstore extension
echo "Enabling hstore extension..."
psql -h "$PGDATA" -U "$PGUSER" -d "$PGDATABASE" -c "CREATE EXTENSION hstore;"

# Verify PostGIS is working
echo "Verifying PostGIS installation..."
psql -h "$PGDATA" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT PostGIS_Version();"

# Import test data with osm2pgsql
echo "Importing Liechtenstein test data with osm2pgsql..."
TEST_DATA="${RECIPE_DIR:-$(dirname "$0")}/liechtenstein-2013-08-03.osm.pbf"

if [ ! -f "$TEST_DATA" ]; then
    echo "Error: Test data file not found at $TEST_DATA"
    exit 1
fi

echo "Using test data file: $TEST_DATA"
osm2pgsql --create --slim --latlong \
    --database="$PGDATABASE" --host="$PGDATA" --user="$PGUSER" \
    --hstore \
    "$TEST_DATA"

# Verify data was imported
echo "Verifying data import..."
TABLE_COUNT=$(psql -h "$PGDATA" -U "$PGUSER" -d "$PGDATABASE" -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_name LIKE 'planet_osm%';")
echo "Found $TABLE_COUNT osm2pgsql tables in database"

if [ "$TABLE_COUNT" -lt 1 ]; then
    echo "Error: No osm2pgsql tables found after import"
    exit 1
fi

# Check some basic statistics
echo "Import statistics:"
psql -h "$PGDATA" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT
    (SELECT COUNT(*) FROM planet_osm_point) as points,
    (SELECT COUNT(*) FROM planet_osm_line) as lines,
    (SELECT COUNT(*) FROM planet_osm_polygon) as polygons,
    (SELECT COUNT(*) FROM planet_osm_roads) as roads;"

# Test osm2pgsql-replication
echo "Testing osm2pgsql-replication..."

# We expect this to fail, but the next command makes sure the right
# records were created
osm2pgsql-replication init \
    --database="$PGDATABASE" --host="$PGDATA" --user="$PGUSER" \
    --osm-file "$TEST_DATA" || true

psql -h "$PGDATA" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT * FROM osm2pgsql_properties;" |
    grep "replication_base_url"

if [[ $? -ne 0 ]]; then
    echo "Replication setting not found"
    exit 1
fi

echo "Test completed successfully!"

# Cleanup
echo "Stopping PostgreSQL and cleaning up..."
pg_ctl -D "$PGDATA" stop
rm -rf "$PGDATA"
