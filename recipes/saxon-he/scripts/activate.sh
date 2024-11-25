# First backup the varialbles if they are set.
# The variables are allowed to be empty (Null).
# Then set the variables to the location of this package.
# The deactivate script restores the backed up variables.

# The CLASSPATH is set to the location of the jar files.
SaxonHE_HOME="${CONDA_PREFIX}/lib/SaxonHE"

if [ "${CLASSPATH+x}" ] ; then
  export CLASSPATH_CONDA_BACKUP="${CLASSPATH}"
else
  export CLASSPATH=""
fi

for jar in $(ls ${SaxonHE_HOME}/*.jar); do
  export CLASSPATH="${jar}:${CLASSPATH}"
done
