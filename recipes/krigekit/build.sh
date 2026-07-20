#!/bin/bash
set -euo pipefail

python build_lib.py --compiler gfortran
pip install . --no-deps --no-build-isolation -v
