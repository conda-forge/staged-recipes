#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build package with maven
./mvnw install -DskipTests=true -Dmaven.local.repo=$SRC_DIR

# Unpack archive and install JAR files
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
unzip pmd-dist/target/pmd-dist-*-SNAPSHOT-bin.zip
cp -r pmd-bin-*-SNAPSHOT/* ${PREFIX}/libexec/${PKG_NAME}

# Create bash and batch wrappers
tee ${PREFIX}/bin/pmd << EOF
exec \${CONDA_PREFIX}/libexec/pmd/bin/pmd "\$@"
EOF

tee ${PREFIX}/bin/pmd.cmd << EOF
call %CONDA_PREFIX%\libexec\pmd\bin\pmd.bat %*
EOF

# Download licenses and gather them from each subdirectory
./mvnw license:download-licenses -Dgoal=download-licenses
find -type d -name "licenses" | grep generated-resources | grep -v '^./target' | xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'
