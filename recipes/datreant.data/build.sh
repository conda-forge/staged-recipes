#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
rm -f $SP_DIR/*-nspkg.pth
