#!/usr/bin/env bash
set -euxo pipefail

mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/activate-swift.sh"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/deactivate-swift.sh"
