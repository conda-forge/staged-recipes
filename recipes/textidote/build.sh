#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Build and install jar
ant download-deps
ant -noinput -buildfile build.xml -Dbuild.targetjdk=19

install -m 644 textidote.jar ${PREFIX}/libexec/${PKG_NAME}

# Create bash and batch wrappers
tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/textidote/textidote.jar "\$@"
EOF

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\textidote\textidote.jar %*
EOF

# Copy dependency licenses from recipe directory
mkdir -p ${SRC_DIR}/license-files
cp -r ${RECIPE_DIR}/licenses/* ${SRC_DIR}/license-files
