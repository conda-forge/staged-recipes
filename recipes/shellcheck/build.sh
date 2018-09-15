#!/bin/sh

set -o xtrace -o pipefail -o errexit

BINARY_HOME=${PREFIX}/bin
PACKAGE_HOME=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
export STACK_ROOT=${PACKAGE_HOME}/stackroot
export LIBRARY_PATH=${LIBRARY_PATH}:${PREFIX}/lib # required for gmp etc. to be found

mkdir -p "${BINARY_HOME}"
mkdir -p "${PACKAGE_HOME}"
mkdir -p "${STACK_ROOT}"

STACK_OPTS=\
"--local-bin-path ${PREFIX}/bin "\
"--extra-include-dirs ${PREFIX}/include "\
"--extra-lib-dirs ${PREFIX}/lib "\
"--stack-root ${STACK_ROOT} "

stack ${STACK_OPTS} setup
stack ${STACK_OPTS} install --ghc-options \
  "-optl-pthread -optl-L${PREFIX}/lib -optl-Wl,-rpath,${PREFIX}/lib"

rm -rf "${PACKAGE_HOME}"
