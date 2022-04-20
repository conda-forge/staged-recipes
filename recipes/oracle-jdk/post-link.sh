#!/bin/bash -euo

{
  echo "Installing in ${CONDA_PREFIX}"
  echo "  CONDA_PREFIX: ${CONDA_PREFIX}"
  echo "  PKG_NAME:     ${PKG_NAME}"
  echo "  PKG_VERSION:  ${PKG_VERSION}"
  echo "  PKG_BUILDNUM: ${PKG_BUILDNUM}"
} > "${CONDA_PREFIX}/.messages.txt"

PKG_BIN="${CONDA_PREFIX}/bin"
PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"

CONDA_MESO="${CONDA_PREFIX}/conda-meso/${PKG_UUID}"
[ -e "%CONDA_MESO%" ] || mkdir -p "${CONDA_MESO}"

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
DISCOVERY_SCRIPT="${CONDA_MESO}/discovery.sh"
echo "Writing pkg-script to ${DISCOVERY_SCRIPT}" >> "${CONDA_PREFIX}/.messages.txt"
echo "export ORACLE_JDK_DIR=${ORACLE_JDK_DIR}" > "$DISCOVERY_SCRIPT"

echo "Preparing to link *.exe files, from ${ORACLE_JDK_DIR}." >> "${CONDA_PREFIX}/.messages.txt"

UNLINK_SCRIPT="${CONDA_MESO}/unlink-aux.sh"
echo "Writing revert-script to ${UNLINK_SCRIPT}" >> "${CONDA_PREFIX}/.messages.txt"
printf "#!/bin/bash -euo\n" > "${UNLINK_SCRIPT}"

[ -d "${PKG_BIN}" ] || mkdir -p "${PKG_BIN}"
for ix in "${ORACLE_JDK_DIR}"/bin/*; do
  BASE_NAME=$(basename -- "${ix}")
  jx="${PKG_BIN}/${BASE_NAME}"
  if [ -f  "$jx" ] ; then
    rm "$jx"
    echo "link ${jx} already exists" >> "${CONDA_PREFIX}/.messages.txt"
  fi

  ln -s "${ix}" "${jx}" || echo "failed creating link ${jx} to ${ix}" >> "${CONDA_PREFIX}/.messages.txt"
  echo "# ln -s \"${ix}\" \"${jx}\"" >> "${UNLINK_SCRIPT}"
  echo "rm \"${jx}\"" >> "${UNLINK_SCRIPT}"
done

exit 0
