#!/bin/bash

# Confirm if idsinfo command is available
idsinfo --help

# Confirm required environment variables are set
echo "IMAS_VERSION: ${IMAS_VERSION}"
echo "IMAS_PREFIX: ${IMAS_PREFIX}"

# Confirm if the environment variables are set correctly
if [[ "${IMAS_VERSION}" == "${PKG_VERSION}" ]]; then
    echo "IMAS_VERSION is set correctly"
else
    echo "IMAS_VERSION is not set correctly"
    exit 1
fi
if [[ "${IMAS_PREFIX}/include/IDSDef.xml" == "$(idsinfo idspath)" ]]; then
    echo "IMAS_PREFIX is set correctly"
else
    echo "IMAS_PREFIX is not set correctly"
    exit 1
fi
