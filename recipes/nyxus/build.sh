#!/bin/bash

set -e # Abort on error.

PY_VER=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")
PY_ABIFLAGS=$(python -c "import sys; print('' if sys.version_info.major == 2 else sys.abiflags)")
PY_ABI=${PY_VER}${PY_ABIFLAGS}

CMAKE_ARGS="-DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX -DUSEGPU=ON -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15" python setup.py install
