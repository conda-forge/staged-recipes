#!/bin/bash

set -e

./configure --prefix $PREFIX
make
# To run this check we need to have access to a mssql instance.
# make check
make install
