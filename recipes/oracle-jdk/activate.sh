#!/bin/bash -euo

PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"
REVERT_SCRIPT="${CONDA_PREFIX}\conda-activate-meta\${PKG_UUID}\deactivate-aux.bat"

REVERT_SCRIPT="${CONDA_PREFIX}\conda-link-meta\${PKG_UUID}\pre-unlink-aux.bat"
touch "${REVERT_SCRIPT}"
echo "JAVA_HOME=${JAVA_HOME}" >> "${REVERT_SCRIPT}"

export JAVA_HOME="${ProgramFiles}\Java\jdk1.8.0_321"
