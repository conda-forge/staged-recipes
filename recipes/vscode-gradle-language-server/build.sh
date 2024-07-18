#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Add plugin for dependency licenses
sed -i "s/id 'java'/id 'java'\nid('com.github.jk1.dependency-license-report') version 'latest.release'/" build.gradle

# Build JAR with gradle
./gradlew build

# Download dependency licenses
./gradlew generateLicenseReport

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
cp -r extension/lib/* ${PREFIX}/libexec/${PKG_NAME}

# Create bash and batch wrappers
tee ${PREFIX}/bin/gradle-language-server << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/libexec/gradle-language-server/gradle-server "\$@"
EOF

tee ${PREFIX}/bin/gradle-language-server.cmd << EOF
call %CONDA_PREFIX%\libexec\gradle-language-server\gradle-server.bat %*
EOF
