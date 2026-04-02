#!/bin/sh

set -ex

# nuke vendored libraries
rm -rf mip/libraries/

export SETUPTOOLS_SCM_PRETEND_VERSION="$PKG_VERSION"

python -m pip install . -vv --prefix=$PREFIX
