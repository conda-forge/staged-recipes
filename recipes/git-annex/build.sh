#!/bin/sh

set -e -o pipefail -x

echo BUILDING GIT ANNEX

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

export CPPFLAGS=-I${PREFIX}/include
export LDFLAGS="-L${PREFIX}/lib64 -L${PREFIX}/lib"

echo prefix is $PREFIX
echo env is
env
echo pkgs are
conda list

export STACK_ROOT=$PACKAGE_HOME/stackroot
mkdir -p $STACK_ROOT
#install_cabal_package --constraint 'fingertree<0.1.2.0' --constraint 'aws<0.17' --allow-newer=aws:time

echo >> stack.yaml
echo "local-bin-path: $PREFIX" >> stack.yaml
echo "extra-include-dirs:" >> stack.yaml
echo "- $PREFIX/include" >> stack.yaml
echo "extra-lib-dirs:" >> stack.yaml
echo "- $PREFIX/lib64" >> stack.yaml
echo "- $PREFIX/lib" >> stack.yaml

echo "STACK YAML IS"
cat stack.yaml

STACK_OPTS="--local-bin-path ${PREFIX}/bin --extra-lib-dirs ${PREFIX}/lib64 --extra-lib-dirs ${PREFIX}/lib --extra-include-dirs ${PREFIX}/include -v --stack-root ${STACK_ROOT}"
export DYNAMIC_GHC_PROGRAMS=NO
export DYNAMIC_TOO=NO
echo IS THERE GMP?
ls -alt $PREFIX/lib

stack ${STACK_OPTS} setup
stack path
stack ${STACK_OPTS} install --cabal-verbose --no-executable-stripping --ghc-options "-optl-static -v -optl-L${PREFIX}/lib64 -optl-L${PREFIX}/lib"
