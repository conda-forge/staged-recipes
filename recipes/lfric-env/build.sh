#!/usr/bin/env bash
set -euxo pipefail

# lfric-env ships no compiled artefact: the package IS its dependency closure
# (recipe.yaml) plus this activation contract. There is no `source:` in the
# recipe, so the build directory is empty and the scripts are read from
# $RECIPE_DIR.
: "${RECIPE_DIR:?RECIPE_DIR must be set by the build tool}"

# See the header of activate.sh / deactivate.sh for why the `zzz-` and `000-`
# prefixes matter: conda sources both directories in sorted order, so
# this script must run after conda-forge's compiler activation and before its
# deactivation.
install -d "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
install -m 0644 "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/zzz-lfric-env.sh"
install -m 0644 "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/000-lfric-env.sh"
