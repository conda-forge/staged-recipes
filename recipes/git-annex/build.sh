#!/bin/sh

set -e -o pipefail -x

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME


export STACK_ROOT=$PACKAGE_HOME/stackroot
mkdir $STACK_ROOT
install_cabal_package --constraint 'fingertree<0.1.2.0' --constraint 'aws<0.17' --allow-newer=aws:time 
