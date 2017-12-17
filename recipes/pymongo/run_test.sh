#!/bin/bash
# We don't run on OSX the full tests due to timeout errors
# See https://travis-ci.org/conda-forge/pymongo-feedstock/builds/311631125
if [ "${TRAVIS}" != true ]; then
    unset REQUESTS_CA_BUNDLE
    unset SSL_CERT_FILE

    export DB_PATH="$SRC_DIR/temp-mongo-db"
    export LOG_PATH="$SRC_DIR/mongolog"
    export DB_PORT=27272
    export PID_FILE_PATH="$SRC_DIR/mongopidfile"

    mkdir "$DB_PATH"

    mongod --dbpath="$DB_PATH" --fork --logpath="$LOG_PATH" --port="$DB_PORT" --pidfilepath="$PID_FILE_PATH"

    python setup.py test

    # Terminate the forked process after the test suite exits
    kill `cat $PID_FILE_PATH`
fi
