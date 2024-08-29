#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Add plugin for dependency licenses
sed -i "s/id 'java'/id 'java'\nid('com.github.jk1.dependency-license-report') version 'latest.release'/" build.gradle

# Build JAR
./gradlew shadowJar

# Download dependency licenses
./gradlew generateLicenseReport

cp build/libs/${PKG_NAME}-${PKG_VERSION}.jar ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}.jar

tee ${PREFIX}/bin/${PKG_NAME} << EOF
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/crowdin-cli/crowdin-cli.jar \$@
EOF

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\crowdin-cli\crowdin-cli.jar %*
EOF
