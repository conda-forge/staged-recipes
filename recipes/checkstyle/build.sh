#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build with maven
cd checkstyle
mvn -e -P assembly package -DskipTests=true
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Install JAR files
cp target/checkstyle-${PKG_VERSION}-all.jar ${PREFIX}/libexec/${PKG_NAME}/checkstyle.jar

# Create bash and batch files
tee ${PREFIX}/bin/checkstyle << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/checkstyle/checkstyle.jar "\$@"
EOF

tee ${PREFIX}/bin/checkstyle.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\checkstyle/checkstyle.jar %*
EOF

# Download licenses
mvn license:download-licenses -Dgoal=download-licenses
