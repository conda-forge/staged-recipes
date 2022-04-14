#!/bin/bash -euo

echo "Installing in ${CONDA_PREFIX}" > "${CONDA_PREFIX}/.messages.txt"
echo "   CONDA_PREFIX: ${CONDA_PREFIX}" > "${CONDA_PREFIX}/.messages.txt"
echo "   PKG_NAME:     ${PKG_NAME}"     > "${CONDA_PREFIX}/.messages.txt"
echo "   PKG_VERSION:  ${PKG_VERSION}"  > "${CONDA_PREFIX}/.messages.txt"
echo "   PKG_BUILDNUM: ${PKG_BUILDNUM}" > "${CONDA_PREFIX}/.messages.txt"

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
  echo "The target JDK version has not been installed. ${SRC_DIR}" >> "${CONDA_PREFIX}/.messages.txt"
  echo "see https://www.oracle.com/java/technologies/downloads/#java8-windows" >> "${CONDA_PREFIX}/.messages.txt"
  exit 1
fi

echo "Preparing to link *.exe files, from ${SRC_DIR}." >> "${CONDA_PREFIX}/.messages.txt"

REVERT_SCRIPT="${CONDA_PREFIX}/conda-link-meta/${PKG_UUID}/pre-unlink-aux.sh"
touch "${REVERT_SCRIPT}"

[ -d "${PKG_BIN}" ] || mkdir -p "${PKG_BIN}"
for ix in "${SRC_DIR}/bin"/*.exe; do
  BASE_NAME=$(basename -- "${ix}")
  ln "${PKG_BIN}/${BASE_NAME}" "${ix}" || echo "failed linking ${PKG_BIN}/${BASE_NAME} ${ix}" >> "${CONDA_PREFIX}/.messages.txt"
  echo "rm \"${PKG_BIN}/${BASE_NAME}\"" >> "${REVERT_SCRIPT}"
done

exit 0
