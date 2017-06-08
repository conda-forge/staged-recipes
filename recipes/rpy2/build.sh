#!/bin/bash

if [[ $(uname) == "Linux" && ${ARCH} == 32 && ${PY_VER} == 3.6 ]]; then
  # See https://bitbucket.org/rpy2/rpy2/issues/389/failed-to-compile-with-python-360-on-32
  export CFLAGS=" -DHAVE_UINTPTR_T=1"
fi

python setup.py install --single-version-externally-managed --record=record.txt
