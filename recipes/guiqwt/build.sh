#!/usr/bin/env bash

$PYTHON setup.py build --fcompiler=gnu95
$PYTHON setup.py install --prefix=$PREFIX --single-version-externally-managed --record=record.txt
