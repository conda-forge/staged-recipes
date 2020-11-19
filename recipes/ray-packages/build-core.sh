#!/bin/bash
set -xe

cd python/
export SKIP_THIRDPARTY_INSTALL=1
"${PYTHON}" setup.py install
