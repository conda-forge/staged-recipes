#!/bin/bash

set -exuo pipefail

make build
mkdir -p ${PREFIX}/bin
make install