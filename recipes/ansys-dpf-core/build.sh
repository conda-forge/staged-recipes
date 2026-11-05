#!/bin/bash
set -ex

GATEBIN="src/ansys/dpf/gatebin"

# Remove Windows binaries
rm -f "$GATEBIN"/*.dll

# On macOS, also remove Linux binaries (no native libs for macOS)
if [[ "$(uname)" == "Darwin" ]]; then
    rm -f "$GATEBIN"/*.so
fi

pip install . --no-deps --no-build-isolation -vv