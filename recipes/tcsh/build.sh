#!/bin/bash
set -eu -o pipefail

./configure 
make
make install

