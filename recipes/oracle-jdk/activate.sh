#!/bin/bash -euo

PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"
MESO_DIR="${CONDA_PREFIX}/conda-meso/${PKG_UUID}"
[ -e "${MESO_DIR}" ] || mkdir -p "${MESO_DIR}"

DISCOVER_SCRIPT="${MESO_DIR}/discovery.sh"
if [ -f "${DISCOVER_SCRIPT}" ]; then
  source "${DISCOVER_SCRIPT}"
fi

REVERT_SCRIPT="${MESO_DIR}/deactivate-aux.sh"
printf "#!/bin/bash -euo\n" > "${REVERT_SCRIPT}"
echo "Writing revert-script to ${REVERT_SCRIPT}"

echo "JAVA_HOME=${JAVA_HOME}" >> "${REVERT_SCRIPT}"
# the post-link script should have set ORACLE_JDK_DIR
export JAVA_HOME="${ORACLE_JDK_DIR}/jdk1.8.0_321"
