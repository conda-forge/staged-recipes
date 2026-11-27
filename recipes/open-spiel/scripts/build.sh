#!/usr/bin/env bash

set -euxo pipefail

python "${RECIPE_DIR}/scripts/rewrite_system_includes.py"

export BUILD_TYPE=Release
export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT}"
export CMAKE_GENERATOR=Ninja
export OPEN_SPIEL_ENABLE_JAX=OFF
export OPEN_SPIEL_ENABLE_PYTORCH=OFF
export OPEN_SPIEL_BUILDING_WHEEL=ON

"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
