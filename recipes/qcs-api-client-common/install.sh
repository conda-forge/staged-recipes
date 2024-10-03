#!/usr/bin/env bash

set -exuo pipefail

${PYTHON} -m pip install qcs-api-client-common \
  --no-build-isolation \
  --no-deps \
  --only-binary :all: \
  --find-links=wheels/ \
  --prefix "${PREFIX}"
