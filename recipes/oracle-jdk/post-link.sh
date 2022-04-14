#!/bin/bash -euo

echo "Installing in ${CONDA_PREFIX}" > "${PREFIX}/.messages.txt"
echo "   CONDA_PREFIX: ${CONDA_PREFIX}" > "${PREFIX}/.messages.txt"
echo "   PREFIX:       ${PREFIX}"       > "${PREFIX}/.messages.txt"
echo "   PKG_NAME:     ${PKG_NAME}"     > "${PREFIX}/.messages.txt"
echo "   PKG_VERSION:  ${PKG_VERSION}"  > "${PREFIX}/.messages.txt"
echo "   PKG_BUILDNUM: ${PKG_BUILDNUM}" > "${PREFIX}/.messages.txt"

PKG_BIN="${CONDA_PREFIX}/bin"
PKG_INC="${CONDA_PREFIX}/include"
PKG_JRE="${CONDA_PREFIX}/jre"
PKG_JRE_BIN="${CONDA_PREFIX}/jre/bin"
PKG_JRE_LIB="${CONDA_PREFIX}/jre/lib"
PKG_LIB="${CONDA_PREFIX}/lib"
PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"

# What is the best way to get the path?
SRC_DIR="/usr/bin/Java/jdk1.8.0_321"

# Discovery
SetLocal EnableExtensions EnableDelayedExpansion
if [ -d "${SRC_DIR}" ]; then 
  echo "The target JDK version has not been installed. ${SRC_DIR}" >> "${PREFIX}/.messages.txt"
  echo "see https://www.oracle.com/java/technologies/downloads/#java8-windows" >> "${PREFIX}/.messages.txt"
  exit 1
fi

echo "Preparing to link *.exe files, from ${SRC_DIR}." >> "${PREFIX}/.messages.txt"

REVERT_SCRIPT="${CONDA_PREFIX}/conda-link-meta/${PKG_UUID}/pre-unlink-aux.sh"
touch "${REVERT_SCRIPT}"

[ -d "${PKG_BIN}" ] || mkdir -p "${PKG_BIN}"
for ix in "${SRC_DIR}/bin"/*.exe; do
  BASE_NAME=$(basename -- "${ix}")
  ln "${PKG_BIN}/${BASE_NAME}" "${ix}" || echo "failed linking ${PKG_BIN}/${BASE_NAME} ${ix}" >> "${PREFIX}/.messages.txt"
  echo "rm \"${PKG_BIN}/${BASE_NAME}\"" >> "${REVERT_SCRIPT}"
done

exit 0
