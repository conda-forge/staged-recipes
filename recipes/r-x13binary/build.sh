#!/bin/bash

set -o errexit -o pipefail

if [[ ${target_platform} =~ linux.* ]] || [[ ${target_platform} == win-32 ]] || [[ ${target_platform} == win-64 ]] || [[ ${target_platform} == osx-64 ]]; then
  export DISABLE_AUTOBREW=1
  mv DESCRIPTION DESCRIPTION.old
  grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION
  ${R} CMD INSTALL --build .
else
  mkdir -p "${PREFIX}"/lib/R/library/x13binary
  mv ./* "${PREFIX}"/lib/R/library/x13binary
fi

# Use our libgcc_s.1.dylib
if [[ $target_platform == osx-64 ]]; then
  pushd "${PREFIX}"
    for SHARED_LIB in lib/R/library/x13binary/lib/libquadmath.0.dylib lib/R/library/x13binary/lib/libgfortran.3.dylib; do
      ${INSTALL_NAME_TOOL} -change "@executable_path/../lib/libgcc_s.1.dylib" "${PREFIX}/lib/libgcc_s.1.dylib" ${SHARED_LIB}
    done
    rm lib/R/library/x13binary/lib/libgcc_s.1.dylib

  # .. and our libquadmath.0.dylib and libgfortran.3.dylib
  pushd "${PREFIX}"
    for EXE in lib/R/library/x13binary/bin/x13ashtml; do
      ${INSTALL_NAME_TOOL} -change "@executable_path/../lib/libgcc_s.1.dylib" "${PREFIX}/lib/libgcc_s.1.dylib" ${EXE}
      ${INSTALL_NAME_TOOL} -change "@executable_path/../lib/libgfortran.3.dylib" "${PREFIX}/lib/libgfortran.3.dylib" ${EXE}
      ${INSTALL_NAME_TOOL} -change "@executable_path/../lib/libquadmath.0.dylib" "${PREFIX}/lib/libquadmath.0.dylib" ${EXE}
    done
    rm lib/R/library/x13binary/lib/libquadmath.0.dylib
  popd
fi
