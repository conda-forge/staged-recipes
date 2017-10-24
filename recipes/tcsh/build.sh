#!/bin/bash
set -eu -o pipefail

export LDFLAGS="-L/lib64 -L/usr/lib64 -L/lib -L/usr/lib"

./configure 
make
make install

