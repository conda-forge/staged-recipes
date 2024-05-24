#!/bin/bash

INSTALL_DIR="${PREFIX}/bin"
MVN_REPOSITORY="${PREFIX}/lib/stim"

mkdir -p ${INSTALL_DIR}
mkdir -p ${MVN_REPOSITORY}

./install.sh -i ${INSTALL_DIR} -r ${MVN_REPOSITORY}

# delete hard-coded memory limit
find ${INSTALL_DIR} -name "st-*" | xargs sed -i '/Xmx/d'

