#! /bin/bash

set -xeuo pipefail

# This file is patched, but here we need to complete the modification
# to supply a default "siteconfig" file inside $PREFIX.
sed -i -e "s|@PREFIX@|$PREFIX|" casaconfig/config.py

mkdir -p $PREFIX/share/casa

cat >$PREFIX/share/casa/casasiteconfig.py <<EOF
# conda-forge CASA site config
# See: https://casadocs.readthedocs.io/en/stable/api/casaconfig.html#config-py
# We cannot stub an empty directory in a Conda package, and the casaconfig
# initialization logic relies a lot on new data dirs being exactly empty, so:

import os

# NB: __file__ is not available since this code is exec()ed
measurespath = "$PREFIX/share/casa/data"

try:
    os.mkdir(measurespath)
except FileExistsError:
    pass

datapath = [measurespath]
EOF

python -m pip install . -vv --no-deps --no-build-isolation
rm -rfv $SP_DIR/tests
