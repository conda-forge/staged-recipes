#!/bin/bash

set -vxeuo pipefail

export PYTHONPATH=$PWD/scripts/

cd shared-data/python/
$PYTHON setup.py bdist_wheel
$PYTHON -m pip install dist/*.whl

