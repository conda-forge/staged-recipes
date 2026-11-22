#!/bin/bash
set -euxo pipefail
export npm_config_cache="${SRC_DIR}/.npm-cache"
export NODE_GYP_FORCE_PYTHON="${BUILD_PREFIX}/bin/python"
export NODE_USE_SYSTEM_CA=1
export SCARF_ANALYTICS=false
export DO_NOT_TRACK=1

python "${RECIPE_DIR}/build_support.py" prepare
npm install --global --prefix "${PREFIX}" --install-links --ignore-scripts --omit=dev --no-audit --no-fund .
LETTA_ROOT="${PREFIX}/lib/node_modules/@letta-ai/letta-code"
python "${RECIPE_DIR}/build_support.py" native "${LETTA_ROOT}"
node "${LETTA_ROOT}/scripts/postinstall-patches.js"
python "${RECIPE_DIR}/licenses.py" "${LETTA_ROOT}" "${SRC_DIR}/bundled-licenses" "${SRC_DIR}/THIRDPARTY.txt"
