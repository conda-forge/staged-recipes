#!/bin/bash

set -exuo pipefail

./configure --prefix="${PREFIX}"
make install "-j${CPU_COUNT}"
