#!/usr/bin/env bash

set -ex

${PYTHON} -m pip wheel -w wheels . \
  --no-build-isolation \
  --no-deps \
  --only-binary :all:
