#!/bin/sh

_V=${CONDA_PY:0:1}
_v=${CONDA_PY:1:2}

if [ -z "$MACOSX_DEPLOYMENT_TARGET" ]; then
    export LDFLAGS="-shared $LDFLAGS"
else
    if [ $_V -eq 3 ]; then
	export LDFLAGS="-shared $LDFLAGS -lpython${_V}.${_v}m"
    else
	export LDFLAGS="-shared $LDFLAGS -lpython${_V}.${_v}"
    fi
fi
$PYTHON setup.py install --single-version-externally-managed --record record.txt
