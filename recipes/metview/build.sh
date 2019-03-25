#!/usr/bin/env bash

set -e # Abort on error.

export PING_SLEEP=30s
export BUILD_OUTPUT=$RECIPE_DIR/build.out

touch $BUILD_OUTPUT

dump_output() {
    echo Tailing the last 500 lines of output:
    tail -50000 $BUILD_OUTPUT
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

export PYTHON=
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

BUILD_DIR=$SRC_DIR/../build
mkdir $BUILD_DIR
cd $BUILD_DIR

export TMPDIR=/tmp/

if [[ $(uname) == Linux ]]; then
    SYSROOT_LIB=$BUILD_PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib
    export LDFLAGS="$LDFLAGS -L$SYSROOT_LIB -Wl,-rpath,$SYSROOT_LIB"
fi

# Start Build
cmake $SRC_DIR \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DENABLE_DOCS=0

make -j $CPU_COUNT >> $BUILD_OUTPUT 2>&1

ctest --output-on-failure -j $CPU_COUNT >> $BUILD_OUTPUT 2>&1
make install >> $BUILD_OUTPUT 2>&1

# The build finished without returning an error so dump a tail of the output.
dump_output

# Nicely terminate the ping output loop.
kill $PING_LOOP_PID
