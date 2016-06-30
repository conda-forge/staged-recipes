#!/bin/bash

export DB_PATH="$SRC_DIR/temp-mongo-db"
export LOG_PATH="$SRC_DIR/mongolog"
export DB_PORT=27272
export PID_FILE_PATH="$SRC_DIR/mongopidfile"

mkdir "$DB_PATH"

mongod --dbpath="$DB_PATH" --fork --logpath="$LOG_PATH" --port="$DB_PORT" --pidfilepath="$PID_FILE_PATH"

pushd $SRC_DIR

python setup.py test

# Terminate the forked process after the test suite exits
kill `cat $PID_FILE_PATH`
