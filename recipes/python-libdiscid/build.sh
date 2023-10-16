#!/bin/sh

set -ex

export CYLP_USE_CYTHON=1
export COIN_INSTALL_DIR=$PREFIX

python -m pip install . -vvv
