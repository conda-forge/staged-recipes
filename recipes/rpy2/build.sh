#!/bin/bash

if [[ $(uname) == "Linux" && ${ARCH} == 32 && ${PY_VER} == 3.6 ]]; then
  # See https://bitbucket.org/rpy2/rpy2/issues/389/failed-to-compile-with-python-360-on-32
  CFLAGS="-I${PREFIX}/include ${CFLAGS} -DHAVE_UINTPTR_T=1" "${PYTHON}" setup.py install --single-version-externally-managed --record=record.txt
else
  CFLAGS="-I${PREFIX}/include ${CFLAGS}" "${PYTHON}" setup.py install --single-version-externally-managed --record=record.txt
fi
