#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit


# Build with maven
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

sed -i 's/id("junitbuild.temp-maven-repo")/id("junitbuild.temp-maven-repo")\nid("com.github.jk1.dependency-license-report") version "latest.release"/' build.gradle.kts

unset CI
./gradlew build -x signMavenPublication -x publishMavenPublicationToTempRepository -x test

./gradlew generateLicenseReport

platform_version=$(grep "platformVersion" < gradle.properties | tr -s ' ' | cut -d ' ' -f 3)
cp ${SRC_DIR}/junit-platform-console-standalone/build/libs/junit-platform-console-standalone-${platform_version}.jar \
    ${PREFIX}/libexec/${PKG_NAME}/junit-platform-console-standalone.jar

# Create bash and batch files
tee ${PREFIX}/bin/junit5 << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/junit5/junit-platform-console-standalone.jar "\$@"
EOF

tee ${PREFIX}/bin/junit5.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\junit5/junit-platform-console-standalone.jar %*
EOF
