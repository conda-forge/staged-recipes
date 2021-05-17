#!/bin/sh

set -ex

export COIN_INSTALL_DIR=$PREFIX
python -m pip install . -vv
