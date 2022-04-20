
# PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"
CONDA_MESO="${CONDA_PREFIX}/conda-meso/${PKG_UUID}"
[ -e "${CONDA_MESO}" ] || mkdir -p "${CONDA_MESO}"

DISCOVER_SCRIPT="${CONDA_MESO}/discovery.sh"
if [ -f "${DISCOVER_SCRIPT}" ]; then
  source "${DISCOVER_SCRIPT}"
fi

DEACTIVATE_SCRIPT="${CONDA_MESO}/deactivate-aux.sh"
printf "#!/bin/bash -euo\n" > "${DEACTIVATE_SCRIPT}"
echo "Writing revert-script to ${DEACTIVATE_SCRIPT}"


echo "#  JDK8_HOME=\"${ORACLE_JDK_DIR}\"" >> "${DEACTIVATE_SCRIPT}"
echo "JDK8_HOME=${JDK8_HOME}" >> "${DEACTIVATE_SCRIPT}"
# the post-link script should have set ORACLE_JDK_DIR
export JDK8_HOME="${ORACLE_JDK_DIR}"

echo "# JAVA_HOME=\"${ORACLE_JDK_DIR}\"" >> "${DEACTIVATE_SCRIPT}"
echo "JAVA_HOME=${JAVA_HOME}" >> "${DEACTIVATE_SCRIPT}"
# the post-link script should have set ORACLE_JDK_DIR
export JAVA_HOME="${ORACLE_JDK_DIR}"
