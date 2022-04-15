#!/bin/bash -euo

{
  echo Installing in ${CONDA_PREFIX}
  echo   CONDA_PREFIX: ${CONDA_PREFIX}
  echo   PKG_NAME:     ${PKG_NAME}
  echo   PKG_VERSION:  ${PKG_VERSION}
  echo   PKG_BUILDNUM: ${PKG_BUILDNUM}
} > "${CONDA_PREFIX}/.messages.txt"

PKG_BIN="${CONDA_PREFIX}/bin"
PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"

MESO_DIR="${CONDA_PREFIX}/conda-meso/${PKG_UUID}"
[ -e "%MESO_DIR%" ] || mkdir -p "${MESO_DIR}"

# Discovery
# This is where the rpm puts it.
WIP=0
for gx in /usr/java/jdk1.8.0_*; do
  BASE_NAME=$(basename -- "${gx}")
  BACK=${BASE_NAME##jdk1.8.0_}
  REVISION=${BACK%-*}
  if [ "$REVISION" -gt "$WIP" ]; then
    WIP=$REVISION
    export ORACLE_JDK_DIR="$gx"
  fi
done

if [ ! -d "${ORACLE_JDK_DIR}" ]; then
  {
    echo "The target JDK version has not been installed. ${ORACLE_JDK_DIR}";
    echo "see https://www.oracle.com/java/technologies/downloads/#java8-linux";
    echo " jdk-8u321-linux-x64.rpm "
  } >> "${CONDA_PREFIX}/.messages.txt"
  exit 0
fi
DISCOVER_SCRIPT="${MESO_DIR}/discovery.sh"
echo "Writing pkg-script to ${DISCOVER_SCRIPT}" >> "${CONDA_PREFIX}/.messages.txt"
echo "export ORACLE_JDK_DIR=${ORACLE_JDK_DIR}" > "$DISCOVER_SCRIPT"

echo "Preparing to link *.exe files, from ${ORACLE_JDK_DIR}." >> "${CONDA_PREFIX}/.messages.txt"

REVERT_SCRIPT="${MESO_DIR}/pre-unlink-aux.sh"
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
