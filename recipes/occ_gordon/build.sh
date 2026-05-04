#!/bin/bash
set -euo pipefail

cd python
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
