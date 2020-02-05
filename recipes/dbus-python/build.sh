#!/bin/bash

set -ex

# NOTE: this configuration duplicates a bunch of effort, because I
#       don't know how to get `pip` to use the current directory
#       for the build - we want to use pip because it handles metadata
#       much better than pure setuptools

# install non-python extras
mkdir -p _build
pushd _build
${SRC_DIR}/configure \
	--prefix=${PREFIX} \
;
make -j ${CPU_COUNT}
if [ "$(uname)" == "Linux" ]; then  # tests fail on osx...
    make -j ${CPU_COUNT} check
fi
make -j ${CPU_COUNT} install
popd

# build and install python
${PYTHON} -m pip install . -vv --no-cache-dir --no-deps
