#!/bin/bash
set -x
set -e

./configure --prefix=$PREFIX
make
make install
