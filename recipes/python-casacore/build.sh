#! /bin/bash

set -e
IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug

export CFLAGS="-I$PREFIX/include"

python setup.py install --single-version-externally-managed --record record.txt
