#!/bin/bash

set -eu -o pipefail

export LD_FLAGS="/lib64"

eval ./configure
cat config.log 
make
make install

