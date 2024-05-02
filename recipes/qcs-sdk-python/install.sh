#!/bin/bash

set -ex

# Install
${PYTHON} -m pip install qcs-sdk-python \
  --no-build-isolation \
  --no-deps \
  --only-binary :all: \
  --find-links=wheels/ \
  --prefix ${PREFIX}
