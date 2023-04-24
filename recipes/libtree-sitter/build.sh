#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make AMALGAMATED=1
make install PREFIX=${PREFIX}
