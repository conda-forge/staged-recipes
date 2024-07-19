#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Add plugin for dependency licenses
sed -i "s/id 'java'/id 'java'\nid('com.github.jk1.dependency-license-report') version 'latest.release'/" build.gradle

# Build JAR with gradle
./gradlew installDist

# Download dependency licenses
./gradlew generateLicenseReport

mkdir -p ${PREFIX}/libexec
mkdir -p ${PREFIX}/bin
cp -r ${SRC_DIR}/gradle-language-server/build/install/gradle-language-server ${PREFIX}/libexec

# Create bash and batch wrappers
tee ${PREFIX}/bin/gradle-language-server << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/libexec/gradle-language-server/bin/gradle-language-server "\$@"
EOF

tee ${PREFIX}/bin/gradle-language-server.cmd << EOF
call %CONDA_PREFIX%\libexec\gradle-language-server\bin\gradle-language-server.bat %*
EOF
