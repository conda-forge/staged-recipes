#!/bin/bash

FILE="$PREFIX/etc/astrometry.cfg"
DEFAULT="$PREFIX/share/astrometry/astrometry.cfg"
DATADIR="$PREFIX/data"

# Avoid config file to be overwritten

if [ ! -f $FILE ]; then
    cp $DEFAULT $FILE
fi

# Create /data dir

if [ ! -f $DATADIR ]; then
    mkdir -p $DATADIR
fi
