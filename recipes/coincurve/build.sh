#!/bin/bash
set -euo pipefail

python setup.py bdist_egg
python setup.py egg_info

# Prevents call to 'autogen.sh' that causes the conda-recipes build to fail
rm -rf libsecp256k1
python setup.py build_clib

python setup.py install_lib
