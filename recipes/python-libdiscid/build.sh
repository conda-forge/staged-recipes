#!/bin/sh

set -ex

export CYLP_USE_CYTHON=1
export COIN_INSTALL_DIR=$PREFIX
apt-get install python3-dev

python -m pip install . -vvv
