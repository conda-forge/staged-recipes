#!/bin/sh

set -e -o pipefail -x

echo BUILDING GIT ANNEX


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

echo prefix is $PREFIX
echo env is
env
echo pkgs are
conda list

export STACK_ROOT=$PACKAGE_HOME/stackroot
mkdir -p $STACK_ROOT
#install_cabal_package --constraint 'fingertree<0.1.2.0' --constraint 'aws<0.17' --allow-newer=aws:time

STACK_OPTS="--local-bin-path ${PREFIX}/bin --extra-include-dirs ${PREFIX}/include -v --stack-root ${STACK_ROOT}"
export DYNAMIC_GHC_PROGRAMS=NO
export DYNAMIC_TOO=NO
echo IS THERE GMP?
ls -alt $PREFIX/lib
echo ENV BEFORE SETUP
env

mkdir -p ${PREFIX}/bin
echo LOCALBINPATH IS ${PREFIX/bin}
ls -ld ${PREFIX}/bin
stack --version
stack ${STACK_OPTS} setup
stack path
stack ${STACK_OPTS} install --cabal-verbose --no-executable-stripping --ghc-options "-optl-static -v -optl-L${PREFIX}/lib"
