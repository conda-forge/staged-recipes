#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit
touch ${BUILD_PREFIX}/lib/jvm/release

# Build with maven
./mvnw install -T 1 -DskipTests=true -Dmaven.local.repo=$SRC_DIR

# Install JAR files
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
cp -r org.eclipse.jdt.ls.product/target/repository/* ${PREFIX}/libexec/${PKG_NAME}

# Create bash and batch wrappers
tee ${PREFIX}/bin/jdtls << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/libexec/jdtls/bin/jdtls "\$@"
EOF

tee ${PREFIX}/bin/jdtls.cmd << EOF
call %CONDA_PREFIX%\libexec\jdtls\bin\jdtls.bat %*
EOF

# Download licenses and gather them from each subdirectory
./mvnw license:download-licenses -Dgoal=download-licenses
find -type d -name "licenses" | grep generated-resources | grep -v "^./target" | xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'
