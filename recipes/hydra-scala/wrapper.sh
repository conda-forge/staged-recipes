#!/bin/bash
HYDRA_HOME="${CONDA_PREFIX}/lib/hydra-scala"
CLASSPATH=$(find "${HYDRA_HOME}" -name "*.jar" | tr '\n' ':')
exec java -cp "${CLASSPATH}" "$@"
