if [ "${JAVA_HOME+x}" ] ; then
  export JAVA_HOME_CONDA_BACKUP="${JAVA_HOME}"
fi
export JAVA_HOME="${CONDA_PREFIX}/opt/temurin"

if [ "${JAVA_LD_LIBRARY_PATH+x}" ] ; then
  export JAVA_LD_LIBRARY_PATH_BACKUP="${JAVA_LD_LIBRARY_PATH}"
fi
export JAVA_LD_LIBRARY_PATH="${JAVA_HOME}/lib/server"
