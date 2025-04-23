#!/bin/bash
set -xeo pipefail

export SKIP_YASM_BUILD=true

python -m pip install . -vv