#!/bin/bash

set -eux # Abort on error.

PY_ABIFLAGS=$(python -c "import sys; print('' if sys.version_info.major == 2 else sys.abiflags)")
PY_ABI=${PY_VER}${PY_ABIFLAGS}

CMAKE_ARGS="-DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15" python -m pip install .
