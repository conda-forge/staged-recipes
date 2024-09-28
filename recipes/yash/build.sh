#!/bin/bash

set -exuo pipefail

chmod -R 755 "${PREFIX}"

./configure --prefix="${PREFIX}"
make install "-j${CPU_COUNT}"
