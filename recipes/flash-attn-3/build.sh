#!/usr/bin/env bash

set -euxo pipefail

"${PYTHON}" -m pip install ./hopper -vv --no-deps --no-build-isolation
