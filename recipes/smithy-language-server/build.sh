#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Add dependency-license-report as a plugin to build.gradle
sed -i 's/id "java"/id "java"\nid "com.github.jk1.dependency-license-report" version "latest.release"/' build.gradle

# Build with gradle
./gradlew clean build
./gradlew generateLicenseReport
install -m 644 ${SRC_DIR}/build/libs/${PKG_NAME}-${PKG_VERSION}.jar ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}.jar

# Create bash and batch files
tee ${PREFIX}/bin/smithy-language-server << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/smithy-language-server/smithy-language-server.jar "\$@"
EOF

tee ${PREFIX}/bin/smithy-language-server.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\smithy-language-server\smithy-language-server.jar %*
EOF
