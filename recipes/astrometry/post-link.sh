#!/bin/bash

FILE="$PREFIX/etc/astrometry.cfg"
DEFAULT="$PREFIX/share/astrometry/astrometry.cfg"

if [ -f $FILE ]; then
    echo "Existing config file for astrometry.net."
else
    cp $DEFAULT $FILE
fi
