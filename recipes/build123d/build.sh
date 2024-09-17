#!/bin/bash

export SETUPTOOLS_SCM_PRETEND_VERSION="$PKG_VERSION"
echo "version = \"$PKG_VERSION\"" >src/build123d/_version.py
"$PYTHON" -m pip install . -vv --no-deps --no-build-isolation 
