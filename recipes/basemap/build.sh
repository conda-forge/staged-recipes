#!/bin/bash

# Ensure our geos will be used.
rm -rf $SRC_DIR/geos-3.3.3
export GEOS_DIR=$PREFIX

$PYTHON setup.py install

# Remove the data from the site-packages directory.
rm -rf $SP_DIR/mpl_toolkits/basemap/data

# Create the data directory.
DATADIR="$PREFIX/share/basemap"

# Copy all the data.
cp -a $SRC_DIR/lib/mpl_toolkits/basemap/data/ $DATADIR

# But remove the high resolution data. (Packaged separately.)
rm -rf $DATADIR/*_h.dat
rm -rf $DATADIR/*_f.dat
