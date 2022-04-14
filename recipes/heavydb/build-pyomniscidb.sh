#!/bin/sh

set -e
set -x

cd python

$PYTHON setup.py \
        install --single-version-externally-managed \
                --record=record.txt
