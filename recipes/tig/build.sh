#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure
make "prefix=$PREFIX"
make install "prefix=$PREFIX"
