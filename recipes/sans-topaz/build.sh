#!/usr/bin/env bash
set -euo pipefail

export USE_OPENMP=1

cd src
make clean
make

mkdir -p "${PREFIX}/bin"
install -m755 topaz "${PREFIX}/bin/topaz"
