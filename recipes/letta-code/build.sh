# Sourced by brush on every platform.
set -euxo pipefail
export npm_config_cache="${SRC_DIR}/.npm-cache"
export NODE_GYP_FORCE_PYTHON="$(python -c 'import sys; print(sys.executable, end="")')"
export NODE_USE_SYSTEM_CA=1
export SCARF_ANALYTICS=false
export DO_NOT_TRACK=1
NPM_CLI=$(python "${RECIPE_DIR}/build_support.py" npm-cli)
python "${RECIPE_DIR}/build_support.py" prepare
node "${NPM_CLI}" install --global --prefix "${PREFIX}" --install-links --ignore-scripts --omit=dev --no-audit --no-fund .
root=$(python "${RECIPE_DIR}/build_support.py" npm-root)
python "${RECIPE_DIR}/build_support.py" clean "${root}"
python "${RECIPE_DIR}/build_support.py" native "${root}"
(cd "${root}"; node scripts/postinstall-patches.js)
python "${RECIPE_DIR}/licenses.py" "${root}" "${SRC_DIR}/bundled-licenses" "${SRC_DIR}/THIRDPARTY.txt"
python "${RECIPE_DIR}/build_support.py" finish
