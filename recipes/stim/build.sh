#!/bin/bash

INSTALL_DIR="${PREFIX}/bin"
MVN_REPOSITORY="${PREFIX}/lib/stim"

mkdir -p ${INSTALL_DIR}
mkdir -p ${MVN_REPOSITORY}

./install.sh -i ${INSTALL_DIR} -r ${MVN_REPOSITORY}

# delete hard-coded memory limit
TMP_FILE="${INSTALL_DIR}/tmp.txt"
for f in ${INSTALL_DIR}/st-*;
do
    sed '/Xmx/d' "${f}" > "${TMP_FILE}"
    cat "${TMP_FILE}" > "${f}"
done
rm $TMP_FILE

