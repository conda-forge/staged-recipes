#!/bin/sh

set -e -o pipefail -x

BINARY_HOME=${PREFIX}/bin
PACKAGE_HOME=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}

mkdir -p ${BINARY_HOME}
mkdir -p ${PACKAGE_HOME}

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLALGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${PREFIX}/include
export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${PREFIX}/include
export LIBRARY_PATH=${LIBRARY_PATH}:${PREFIX}/lib

export STACK_ROOT=${PACKAGE_HOME}/stackroot
mkdir -p ${STACK_ROOT}

STACK_OPTS="--local-bin-path ${PREFIX}/bin --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib --stack-root ${STACK_ROOT} "

mkdir -p ${PREFIX}/bin

stack ${STACK_OPTS} setup
stack ${STACK_OPTS} install --ghc-options "-optl-L${PREFIX}/lib -optl-Wl,-rpath,${PREFIX}/lib"

ln -s ${PREFIX}/bin/git-annex ${PREFIX}/bin/git-annex-shell
rm -rf ${PACKAGE_HOME}
