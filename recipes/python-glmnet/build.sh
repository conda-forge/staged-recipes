#!/bin/bash

# see https://github.com/numpy/numpy/issues/7427
LDFLAGS="$LDFLAGS -undefined dynamic_lookup -bundle"
$PYTHON -m pip install .
