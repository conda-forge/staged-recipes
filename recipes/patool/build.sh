#!/bin/sh

set -e -o pipefail -x

python setup.py install --single-version-externally-managed --record record.txt
chmod u+x $PREFIX/bin/patool
head $PREFIX/bin/patool
