#!/usr/bin/env bash

set -euxo pipefail

# Headers
if [[ "${target_platform}" == win-* ]]; then
  mkdir -p "${PREFIX}"/Library/include
  cp bindings/blst.h "${PREFIX}"/Library/include
  cp bindings/blst_aux.h "${PREFIX}"/Library/include
else
  mkdir -p "${PREFIX}"/include
  cp bindings/blst.h "${PREFIX}"/include
  cp bindings/blst_aux.h "${PREFIX}"/include
fi
