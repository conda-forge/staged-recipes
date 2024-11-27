#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Add dependency-license-report as a plugin to build.gradle.kts
sed -i 's/alias(libs.plugins.kotlin.jvm) apply false/alias(libs.plugins.kotlin.jvm) apply false\nid("com.github.jk1.dependency-license-report") version "latest.release"/' build.gradle.kts

# Build with gradle
# ignore irrelevant error about missing signature for pushing artifacts to a repository - we are only building a JAR
./gradlew clean shadowJarExecutable || true
cp ktlint-cli/build/libs/ktlint-cli-${PKG_VERSION}-all.jar ${PREFIX}/libexec/${PKG_NAME}/ktlint-cli-all.jar
./gradlew generateLicenseReport

# Create bash and batch files
tee ${PREFIX}/bin/ktlint << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/ktlint/ktlint-cli-all.jar "\$@"
EOF

tee ${PREFIX}/bin/ktlint.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\ktlint\ktlint-cli-all.jar %*
EOF
