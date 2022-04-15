#!/bin/bash -euo

PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"
REVERT_DIR="${CONDA_PREFIX}/conda-meso/${PKG_UUID}"
[ -e "${REVERT_DIR}" ] || mkdir "${REVERT_DIR}"

REVERT_SCRIPT="${REVERT_DIR}/deactivate-aux.sh"
touch "${REVERT_SCRIPT}"
echo "Writing revert-script to ${REVERT_SCRIPT}"

echo "JAVA_HOME=${JAVA_HOME}" >> "${REVERT_SCRIPT}"
# the post-link script should have set ORACLE_JDK_DIR
export JAVA_HOME="${ORACLE_JDK_DIR}/jdk1.8.0_321"
