#!/bin/bash
set -e

# Create activate/deactivate directories

echo "Listing files"
ls -lh

echo "Creating activate/deactivate scripts..."
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

echo "Creation java home"
mkdir -p "${PREFIX}/opt/temurin"

echo "Setting Archive Path"
if [ "$(uname -s)" == "Darwin" ]
then
    ARCHIVE_PATH="Contents/Home/"
else
    ARCHIVE_PATH=""
fi

echo "... set to '$ARCHIVE_PATH'"

echo "Copying java files"
for ITEM in bin conf legal lib NOTICE release
do
    echo "... item $ITEM"
    cp -r ${ARCHIVE_PATH}${ITEM} ${PREFIX}/opt/temurin/
done

echo "Creating symlinks"
ln -sf ${PREFIX}/opt/temurin/bin/java ${PREFIX}/bin/java


# from https://raw.githubusercontent.com/adoptium/containers/refs/heads/main/21/jre/ubuntu/jammy/Dockerfile
export JAVA_HOME="${PREFIX}/opt/temurin"
export PATH="${JAVA_HOME}/bin:${PATH}"
export JAVA_LD_LIBRARY_PATH="${JAVA_HOME}/lib/server"

# Verify Java installation and environment
echo "Java version:"
java -version
echo "JAVA_HOME: ${JAVA_HOME}"
echo "Creating CDS archive..."

java -Xshare:dump
