#!/bin/bash

set -ex


${PYTHON} setup.py install -vv -- -DPython3_EXECUTABLE="${PYTHON}" --
