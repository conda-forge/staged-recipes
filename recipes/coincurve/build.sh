#!/bin/bash
set -euo pipefail

$PYTHON setup.py bdist_egg
$PYTHON setup.py egg_info

# Prevents call to 'autogen.sh' that causes the conda-recipes build to fail
rm -rf libsecp256k1
$PYTHON setup.py build_clib

$PYTHON setup.py install_lib
