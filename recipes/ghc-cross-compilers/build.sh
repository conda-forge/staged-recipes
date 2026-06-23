#!/usr/bin/env bash
set -eu

# Set up binary directory
mkdir -p binary/bin _logs

# For cross-compilation, use target linker; for native use host linker
if [[ "${cross_target_platform:-${target_platform}}" != "${target_platform}" ]]; then
  export MergeObjsCmd="${triplet}-ld"
else
  export MergeObjsCmd=${LD_GOLD:-${LD}}
fi

export M4=${BUILD_PREFIX}/bin/m4
export PYTHON=${BUILD_PREFIX}/bin/python
export PATH=${BUILD_PREFIX}/ghc-bootstrap/bin${PATH:+:}${PATH:-}

"${RECIPE_DIR}"/building/build-"${target_platform}.sh"

if [[ -f "${RECIPE_DIR}"/recipe.yaml ]]; then
  "${RECIPE_DIR}"/install_ghc.sh
fi
