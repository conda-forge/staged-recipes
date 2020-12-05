#!/bin/bash

set -euo pipefail

{
PYTHON="$1"
chmod +x fake-git
mv fake-git git
env PATH=.:"$PATH" "$PYTHON" ci/ext.py build
mv git fake-git
"$PYTHON" -m pip install . -vv
}
