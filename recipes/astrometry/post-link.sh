#!/bin/bash

FILE="$PREFIX/etc/astrometry.cfg"
DEFAULT="$PREFIX/share/astrometry/astrometry.cfg"
DATADIR="$PREFIX/data"

# Avoid config file to be overwritten

if [ -f $FILE ]; then
    echo "Existing config file for astrometry.net."
else
    cp $DEFAULT $FILE
fi

# Create /data dir

if [ -f $DATADIR ]; then
    echo "Existing data dir."
else
    mkdir -p $DATADIR
fi
