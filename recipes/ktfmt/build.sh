#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Build with maven
mvn -B install -DskipTests
install -m 644 core/target/ktfmt-${PKG_VERSION}-jar-with-dependencies.jar ${PREFIX}/libexec/${PKG_NAME}/ktfmt.jar

mvn license:download-licenses -Dgoal=download-licenses

# Create bash and batch files
tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/ktfmt/ktfmt.jar "\$@"
EOF

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\ktfmt\ktfmt.jar %*
EOF

