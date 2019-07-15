#!/usr/bin/env bash
cd research

protoc object_detection/protos/*.proto --python_out=.

$PYTHON setup.py install --single-version-externally-managed --record=record.txt # solution for error: check https://github.com/conda/conda/issues/508
