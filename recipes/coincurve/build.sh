#!/bin/bash
set -euo pipefail

#python setup.py bdist_egg -vv
#python setup.py egg_info -vv

# Prevents call to 'autogen.sh' that causes the conda-recipes build to fail
rm -rf libsecp256k1
python setup.py build_clib -vv

python setup.py install_lib -vv
