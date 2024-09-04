#!/usr/bin/env bash

set -ex

${PYTHON} -m pip wheel -w ${SRC_DIR}/wheels . \
  --no-build-isolation \
  --no-deps \
  --only-binary :all:
