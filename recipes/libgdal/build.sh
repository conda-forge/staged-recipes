#!/bin/bash

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

## START BUILD
# Get rid of any `.la` from defaults.
rm -rf $PREFIX/lib/*.la

# Force python bindings to not be built.
unset PYTHON

if [ $(uname) == Darwin ]; then
    export LDFLAGS="-headerpad_max_install_names"
    OPTS="--enable-rpath"
    export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
    COMP_CC=clang
    COMP_CXX=clang++
    export MACOSX_DEPLOYMENT_TARGET="10.9"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
else
    OPTS="--disable-rpath"
    COMP_CC=gcc
    COMP_CXX=g++
fi

export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"

# `--without-pam` was removed.
# See https://github.com/conda-forge/gdal-feedstock/pull/47 for the discussion.

./configure CC=$COMP_CC \
            CXX=$COMP_CXX \
            --prefix=$PREFIX \
            --with-curl \
            --with-dods-root=$PREFIX \
            --with-expat=$PREFIX \
            --with-freexl=$PREFIX \
            --with-geos=$PREFIX/bin/geos-config \
            --with-hdf4=$PREFIX \
            --with-hdf5=$PREFIX \
            --with-jpeg=$PREFIX \
            --with-kea=$PREFIX/bin/kea-config \
            --with-libjson-c=$PREFIX \
            --with-libtiff=$PREFIX \
            --with-libz=$PREFIX \
            --with-netcdf=$PREFIX \
            --with-openjpeg=$PREFIX \
            --with-pg=$PREFIX/bin/pg_config \
            --with-png=$PREFIX \
            --with-spatialite=$PREFIX \
            --with-sqlite3=$PREFIX \
            --with-static-proj4=$PREFIX \
            --with-xerces=$PREFIX \
            --with-xml2=$PREFIX \
            --without-python \
            $OPTS

make -j $CPU_COUNT >> $BUILD_OUTPUT 2>&1
make install >> $BUILD_OUTPUT 2>&1

# Make sure GDAL_DATA and set and still present in the package.
# https://github.com/conda/conda-recipes/pull/267
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/gdal-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/gdal-deactivate.sh
## END BUILD

# The build finished without returning an error so dump a tail of the output.
dump_output

# Nicely terminate the ping output loop.
kill $PING_LOOP_PID
