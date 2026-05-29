#!/usr/bin/env bash
set -euxo pipefail

export CYCLONEDDS_HOME="$PREFIX"

"$PYTHON" -m pip install . -vv --no-build-isolation
