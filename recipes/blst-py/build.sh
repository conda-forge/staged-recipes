#!/usr/bin/env bash

set -ex

# Install
pushd "${SRC_DIR}"/bindings/python
  if [[ "${target_platform}" == win-* ]]; then
    export CXX=x86_64-w64-mingw32-g++
  else
    export CXX="${CXX}"
  fi

  ${PYTHON} ./run.me
  cat > __init__.py << EOF
from . import _blst

from .blst import (
    SecretKey,
    Scalar,
    P1_Affine,
    P1,
    P1_Affines,
    P2_Affine,
    P2,
    P2_Affines,
    PT,
    Pairing,
    BLST_SUCCESS,
    BLST_BAD_ENCODING,
    BLST_POINT_NOT_ON_CURVE,
    BLST_POINT_NOT_IN_GROUP,
    BLST_AGGR_TYPE_MISMATCH,
    BLST_VERIFY_FAIL,
    BLST_PK_IS_INFINITY,
    G1,
    G2,
    cdata,
    memmove,
    cvar,
    BLS12_381_G1,
    BLS12_381_NEG_G1,
    BLS12_381_G2,
    BLS12_381_NEG_G2
)

EOF
popd
