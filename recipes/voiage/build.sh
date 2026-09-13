#!/usr/bin/env bash
set -euxo pipefail

export GIT_DIR="${SRC_DIR}/.conda-no-git"
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
