#!/usr/bin/env bash

# set -x
set -e

export MN_BUILD=boost

SOURCE_CODE_DIR=${SRC_DIR:-$(dirname $0)/..}

python ${SOURCE_CODE_DIR}/setup.py build_ext
python ${SOURCE_CODE_DIR}/setup.py install
