#!/usr/bin/env bash

find / -name libffi.so.6

$PYTHON setup.py install --single-version-externally-managed --record record.txt
