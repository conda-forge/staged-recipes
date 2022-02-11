#!/bin/bash

set -ex

cd xar
./configure --prefix="$PREFIX"
make
make install
