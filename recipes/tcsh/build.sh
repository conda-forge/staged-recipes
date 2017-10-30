#!/bin/bash
set -eu -o pipefail

ldconfig -v

./configure 
make
make install

