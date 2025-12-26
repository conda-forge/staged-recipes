# First backup the varialbles if they are set.
# The variables are allowed to be empty (Null).
# Then set the variables to the location of this package.
# The deactivate script restores the backed up variables.

if [ "${SCALA_HOME+x}" ] ; then
  export SCALA_HOME_CONDA_BACKUP="${SCALA_HOME}"
fi
export SCALA_HOME="${CONDA_PREFIX}/libexec/scala2"

if [ "${SCALA_LD_LIBRARY_PATH+x}" ] ; then
  export SCALA_LD_LIBRARY_PATH_BACKUP="${SCALA_LD_LIBRARY_PATH}"
fi
export SCALA_LD_LIBRARY_PATH="${SCALA_HOME}/lib"
