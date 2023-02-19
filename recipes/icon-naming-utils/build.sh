#!/bin/bash

set -ex

./configure --prefix=$PREFIX --disable-debug --disable-dependency-tracking
make install
