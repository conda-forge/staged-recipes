#!/usr/bin/env bash
set -euxo pipefail

# The native builder imports humming and its Python runtime dependencies.
export HUMMING_DISABLE_PARALLEL_BUILD=1
"$PYTHON" tools/build_native.py
"$PYTHON" -m pip install . -vv --no-deps --no-build-isolation
