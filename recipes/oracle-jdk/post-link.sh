#!/bin/bash -euo

{
  echo "Installing in ${CONDA_PREFIX}"
  echo "   CONDA_PREFIX: ${CONDA_PREFIX}"
  echo "   PKG_NAME:     ${PKG_NAME}"
  echo "   PKG_VERSION:  ${PKG_VERSION}"
  echo "   PKG_BUILDNUM: ${PKG_BUILDNUM}"
} > "${CONDA_PREFIX}/.messages.txt"

PKG_BIN="${CONDA_PREFIX}/bin"
PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"

# What is the best way to get the path?
# This is where the rpm puts it.
export ORACLE_JDK_DIR="/usr/java/jdk1.8.0_321-amd64/"

# Discovery
SetLocal EnableExtensions EnableDelayedExpansion
if [ ! -d "${ORACLE_JDK_DIR}" ]; then
  {
    echo "The target JDK version has not been installed. ${ORACLE_JDK_DIR}";
    echo "see https://www.oracle.com/java/technologies/downloads/#java8-linux";
    echo " jdk-8u321-linux-x64.rpm "
  } >> "${CONDA_PREFIX}/.messages.txt"
  exit 0
fi

echo "Preparing to link *.exe files, from ${ORACLE_JDK_DIR}." >> "${CONDA_PREFIX}/.messages.txt"

REVERT_DIR="${CONDA_PREFIX}/conda-meso/${PKG_UUID}"
[ -e "%REVERT_DIR%" ] || mkdir -p "${REVERT_DIR}"

REVERT_SCRIPT="${REVERT_DIR}/pre-unlink-aux.sh"
echo "Writing revert-script to ${REVERT_SCRIPT}" >> "${CONDA_PREFIX}/.messages.txt"
printf "#!/bin/bash -euo\n" > "${REVERT_SCRIPT}"

[ -d "${PKG_BIN}" ] || mkdir -p "${PKG_BIN}"
for ix in "${ORACLE_JDK_DIR}"/bin/*.exe; do
  BASE_NAME=$(basename -- "${ix}")
  jx="${PKG_BIN}/${BASE_NAME}"
  if [ ! -f  "$jx" ]; then
    ln "${jx}" "${ix}" || echo "failed linking ${jx} ${ix}" >> "${CONDA_PREFIX}/.messages.txt"
  fi
  echo "rm \"${jx}\"" >> "${REVERT_SCRIPT}"
done

exit 0
