#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir build
cd build
sh ../Build.sh -r -tpax
mkdir ${PREFIX}/bin
install -m 755 pax ${PREFIX}/bin

exit 1
