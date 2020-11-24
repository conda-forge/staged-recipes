#!/bin/bash

set -eo pipefail

./configure --disable-dependency-tracking --disable-silent-rules --prefix=${PREFIX} --enable-shared --disable-static
make -j${CPU_COUNT}
make install
