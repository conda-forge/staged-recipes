#!/bin/sh

set -e

export SETUPTOOLS_SCM_PRETEND_VERSION="$PKG_VERSION"
export PMIP_CBC_LIBRARY=$PREFIX
python -m pip install . -vv
