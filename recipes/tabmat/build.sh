#!/bin/bash

set -euo pipefail

if [[ "${GLM_ARCHITECTURE}" != "default" ]]; then
  if [[ ${target_platform} =~ linux.* ]]; then
    export CFLAGS=${CFLAGS/-march=nocona/}
    export CXXFLAGS=${CFLAGS/-march=nocona/}
  else
    export CFLAGS=${CFLAGS/-march=core2/}
    export CXXFLAGS=${CFLAGS/-march=core2/}
  fi
fi

python -m pip install . --no-deps --ignore-installed -vv --no-use-pep517 --disable-pip-version-check
