#!/usr/bin/env bash
set -eux -o pipefail
./configure --prefix "${PREFIX}"
make
make install
