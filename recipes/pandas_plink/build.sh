#!/usr/bin/env bash

conda install libffi -y

$PYTHON setup.py install --single-version-externally-managed --record record.txt
