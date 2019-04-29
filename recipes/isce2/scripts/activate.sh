#!/bin/bash

if [[ -n "$ISCE_HOME" ]]; then
    export _CONDA_SET_ISCE_HOME=$ISCE_HOME
fi

if [[ -n "$ISCE_STACK" ]]; then
    export _CONDA_SET_ISCE_STACK=$ISCE_STACK
fi


export ISCE_HOME=`$CONDA_PREFIX/bin/python -c "import isce, os; print(os.path.dirname(isce.__file__))" | tail -n 1`


if [ -d $CONDA_PREFIX/share/isce2 ]; then
    export ISCE_STACK=$CONDA_PREFIX/share/isce2
fi


