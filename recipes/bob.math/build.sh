#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"

if [[ `uname` == 'Darwin' ]]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
fi

echo $LD_LIBRARY_PATH
echo $LIBRARY_PATH
echo $MIC_LD_LIBRARY_PATH
echo $NLSPATH
echo $CPATH

$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
