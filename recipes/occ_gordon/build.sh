#!/bin/bash
set -euo pipefail

cd python
HOST_PYTHON="${PYTHON//\\/\/}"
export CMAKE_GENERATOR=Ninja
export CMAKE_ARGS="-DPython3_EXECUTABLE:FILEPATH=${HOST_PYTHON} ${CMAKE_ARGS:-}"
"$PYTHON" -m pip install -v --no-build-isolation .
