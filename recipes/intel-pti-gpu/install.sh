#!/bin/bash

set -euxo pipefail

COMPONENT=Pti_Runtime

if [[ "$PKG_NAME" == "libipti" ]]; then
    COMPONENT=Pti_Development
fi

cmake --install ./sdk/build --component ${COMPONENT} --prefix=${PREFIX}
