#!/usr/bin/env bash

set -eu -o pipefail

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX $SRC_DIR
make
make install

