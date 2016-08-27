#!/bin/sh
# setup env for tests
cd "${SRC_DIR}/tests"
export PATH="${PREFIX}/bin:${PATH}"
export CYCLUS_PATH="${PREFIX}/lib/cyclus"
if [ -z "$CYCLUS_NUC_DATA" ]; then
  export CYCLUS_NUC_DATA="${PREFIX}/share/cyclus/cyclus_nuc_data.h5"
fi

UNAME="$(uname)"
if [ "${UNAME}" == "Darwin" ]; then
  export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib/cyclus:${PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH}"
else
  export LD_LIBRARY_PATH="${PREFIX}/lib/cyclus:${PREFIX}/lib:${LD_LIBRARY_PATH}"
fi

# test that agents exist
${PREFIX}/bin/cyclus -l :cycamore

# run unit tests
${PREFIX}/bin/cycamore_unit_tests
