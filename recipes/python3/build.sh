#!/usr/bin/env bash

if [ -x $PREFIX/bin/python3 ]; then
  echo "This is a placeholder file for the python3 package in a python=3 env" > $PREFIX/share/python3_pkg_placeholder
  exit 0
fi

# If we have got here, we in a Python 2 environment, so we should build and
# install Python 3.

./configure --enable-shared --enable-ipv6 --prefix=$PREFIX
make
make install
