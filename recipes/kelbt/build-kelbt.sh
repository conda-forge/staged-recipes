#!/usr/bin/env bash
set -eux -o pipefail
./configure --prefix "${PREFIX}"
make
make check
make install
make installcheck
