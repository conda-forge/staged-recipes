#!/bin/sh

set -e -o pipefail -x

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

export CPPFLAGS=-I${PREFIX}/include
export CFLAGS=-I${PREFIX}/include
export CXXFLAGS=-I${PREFIX}/include
export CPPFLAGS=-I${PREFIX}/include
export LDFLAGS=-L${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib

export STACK_ROOT=$PACKAGE_HOME/stackroot
mkdir -p $STACK_ROOT

STACK_OPTS="--local-bin-path ${PREFIX}/bin --extra-include-dirs ${PREFIX}/include --stack-root ${STACK_ROOT}"

mkdir -p ${PREFIX}/bin

ls -ld ${PREFIX}/bin
export LD_LIBRARY_PATH=${PREFIX}/lib

stack ${STACK_OPTS} setup
stack ${STACK_OPTS} install --cabal-verbose --no-executable-stripping --ghc-options "-v -optl-L${PREFIX}/lib"
