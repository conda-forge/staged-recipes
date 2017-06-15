#!/bin/bash

set -e

./configure --prefix $PREFIX
make
make install
