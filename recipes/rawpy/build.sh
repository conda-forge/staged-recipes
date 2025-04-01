#!/bin/bash

set -exo pipefail

export RAWPY_USE_SYSTEM_LIBRAW=1

$PYTHON -m pip install . -vv
