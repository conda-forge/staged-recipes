#!/bin/bash

set -exo pipefail

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
