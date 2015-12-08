#!/bin/bash

SETUPCFG=$SRC_DIR\setup.cfg

echo "[options]" > $SETUPCFG
echo "use_cython=True" >> $SETUPCFG
echo "[directories]" >> $SETUPCFG
echo "netCDF4_dir = $PREFIX" >> $SETUPCFG

${PYTHON} setup.py install --single-version-externally-managed --record record.txt
