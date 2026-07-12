#!/bin/bash
set -ex

cd bindings/python
$PYTHON -m pip install . --no-build-isolation -vv
