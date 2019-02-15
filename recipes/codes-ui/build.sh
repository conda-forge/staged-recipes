#!/usr/bin/env bash

set -e # Abort on error.

export PING_SLEEP=30s
export WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export BUILD_OUTPUT=$WORKDIR/build.out

touch $BUILD_OUTPUT

dump_output() {
    echo Tailing the last 500 lines of output:
    tail -500 $BUILD_OUTPUT
}
error_handler() {
    echo ERROR: An error was encountered with the build.
    dump_output
    exit 1
}

# If an error occurs, run our error handler to output a tail of the build.
trap 'error_handler' ERR

# Set up a repeating loop to send some output to Travis.
bash -c "while true; do echo \$(date) - building ...; sleep $PING_SLEEP; done" &
PING_LOOP_PID=$!

if [[ $(uname) == Darwin ]]; then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == Linux ]]; then
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export PYTHON=
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

BASE_DIR="$(pwd)"
SRC_DIR=$BASE_DIR/metview/src/codes_ui
BUILD_DIR=$BASE_DIR/../build
mkdir $BUILD_DIR
cd $BUILD_DIR

export TMPDIR=/tmp/

# Start Build
cmake $SRC_DIR \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_MODULE_PATH=$BASE_DIR/cmake

make -j $CPU_COUNT >> $BUILD_OUTPUT 2>&1
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib

ctest --output-on-failure -j $CPU_COUNT >> $BUILD_OUTPUT 2>&1

make install >> $BUILD_OUTPUT 2>&1

# The build finished without returning an error so dump a tail of the output.
dump_output

# Nicely terminate the ping output loop.
kill $PING_LOOP_PID
