#!/bin/bash
set -e

# Create activate/deactivate directories
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

mkdir -p "${PREFIX}/opt/temurin"
mv bin conf legal lib NOTICE release ${PREFIX}/opt/temurin/

ln -sf ${PREFIX}/opt/temurin/bin/java ${PREFIX}/bin/java

# from https://raw.githubusercontent.com/adoptium/containers/refs/heads/main/21/jre/ubuntu/jammy/Dockerfile
export JAVA_HOME="${PREFIX}/opt/temurin"
export PATH="${JAVA_HOME}/bin:${PATH}"
export JAVA_LD_LIBRARY_PATH="${JAVA_HOME}/lib/server"
java -Xshare:dump
