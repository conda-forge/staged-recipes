# Sourced by brush on every platform.
set -euxo pipefail
export npm_config_cache="${SRC_DIR}/.npm-cache"
export NODE_GYP_FORCE_PYTHON="$(python -c 'import sys; print(sys.executable)')"
export NODE_USE_SYSTEM_CA=1
export SCARF_ANALYTICS=false
export DO_NOT_TRACK=1
NPM_CLI=$(python "${RECIPE_DIR}/build_support.py" npm-cli)
python "${RECIPE_DIR}/build_support.py" prepare
node "${NPM_CLI}" install --global --prefix "${PREFIX}" --install-links --ignore-scripts --omit=dev --no-audit --no-fund .
root="$(node "${NPM_CLI}" root --global --prefix "${PREFIX}")/@letta-ai/letta-code"
python "${RECIPE_DIR}/build_support.py" clean "${root}"
node "${NPM_CLI}" install --prefix "${SRC_DIR}/node-gyp" --ignore-scripts --no-audit --no-fund node-gyp@13.1.0
export NODE_PATH="${SRC_DIR}/node-gyp/node_modules"
python "${RECIPE_DIR}/build_support.py" native "${root}"
(cd "${root}"; node scripts/postinstall-patches.js)
python "${RECIPE_DIR}/licenses.py" "${root}" "${SRC_DIR}/bundled-licenses" "${SRC_DIR}/THIRDPARTY.txt"
python "${RECIPE_DIR}/build_support.py" finish
