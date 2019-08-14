#!/usr/bin/env bash

if [[ $(uname -s) == "Darwin" ]]; then
  if [ -z "$DYLD_FALLBACK_LIBRARY_PATH" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${CONDA_PREFIX}/lib"
  else
    export DYLD_FALLBACK_LIBRARY_PATH="${CONDA_PREFIX}/lib:${DYLD_LIBRARY_PATH}"
  fi
  if [ -z "$DYLD_LIBRARY_PATH" ]; then
    export DYLD_LIBRARY_PATH="${CONDA_PREFIX}/lib"
  else
    export DYLD_LIBRARY_PATH="${CONDA_PREFIX}/lib:${DYLD_LIBRARY_PATH}"
  fi
else
  if [ -z "$LD_LIBRARY_PATH" ]; then
    export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib"
  else
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CONDA_PREFIX}/lib"
  fi
fi

export MAGICK_HOME="${CONDA_PREFIX}/"

echo "DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH"
echo "DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH"
$PYTHON -m pip install . --no-deps --ignore-installed -vvv
