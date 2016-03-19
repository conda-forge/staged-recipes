#!/bin/bash

# Make sure cf_units can find the udunits library.
if [[ $(uname) == Darwin ]]; then
    EXT=dylib
else
    EXT=so
fi

SITECFG=cf_units/etc/site.cfg
echo "[System]" > $SITECFG
echo "udunits2_path = $PREFIX/lib/libudunits2.${EXT}" >> $SITECFG


$PYTHON setup.py install --single-version-externally-managed  --record record.txt
