#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir build
cd build
sh ../Build.sh -r -tpax
mkdir ${PREFIX}/bin
cp pax ${PREFIX}/bin
