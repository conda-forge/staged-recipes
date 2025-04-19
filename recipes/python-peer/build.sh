#!/usr/bin/env bash
set -euxo pipefail

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include/eigen3"
$PYTHON -m pip install . -vv
