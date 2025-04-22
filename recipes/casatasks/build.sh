#! /bin/bash

set -xeuo pipefail
cd casatasks
python ./setup.py build
python ./setup.py install --single-version-externally-managed --root=$PREFIX

# The ~gigabyte CASA data tree gets populated during the build, so:
rm -rf $PREFIX/share/casa/data
