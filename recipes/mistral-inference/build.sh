#!/bin/bash

set -exo pipefail

python -m pip install . -vv --no-deps --no-build-isolation
