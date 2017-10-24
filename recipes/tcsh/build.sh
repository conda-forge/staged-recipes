#!/bin/bash

#set -eu -o pipefail

export LDFLAGS="/lib64"

eval ./configure

cat config.log 
make
make install

