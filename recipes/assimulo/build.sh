#!/bin/sh

if test `uname` = "Darwin"
then
  SHLIB_EXT='.dylib'
else
  SHLIB_EXT='.so'
fi

PY_LIB=`find $PREFIX/lib -name libpython${PY_VER}*${SHLIB_EXT}`

$PYTHON setup.py build --extra-fortran-link-flags="${PY_LIB}"

$PYTHON setup.py install --extra-fortran-link-flags="${PY_LIB}"
