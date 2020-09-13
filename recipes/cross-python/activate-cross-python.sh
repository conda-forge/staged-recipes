#!/bin/bash

if [[ "${CONDA_BUILD:-0}" == "1" && "${CONDA_BUILD_STATE}" != "TEST" ]]; then
  $BUILD_PREFIX/bin/python -m crossenv $PREFIX/bin/python \
      --sysroot $CONDA_BUILD_SYSROOT \
      --without-pip $BUILD_PREFIX/venv \
      --sysconfigdata-file $PREFIX/lib/python$PY_VER/${_CONDA_PYTHON_SYSCONFIGDATA_NAME}.py
  cp $BUILD_PREFIX/venv/cross/bin/python $PREFIX/bin/python
  rm -rf $BUILD_PREFIX/venv/cross
  if [[ -f $PREFIX/lib/python$PY_VER/site-packages/numpy/distutils/site.cfg ]]; then
    rsync -a -I $PREFIX/lib/python$PY_VER/site-packages/numpy/ $BUILD_PREFIX/lib/python$PY_VER/site-packages/numpy/
  fi
fi
