#!/bin/bash
set -euo pipefail

cp "${RECIPE_DIR}/pyproject.toml" "${SRC_DIR}/python/runfiles/"
cd "${SRC_DIR}/python/runfiles"
sed -i.bak "s/version = \"0.0.0\"/version = \"${PKG_VERSION}\"/" pyproject.toml

${PYTHON} -m pip install --no-deps --no-build-isolation . -vv
