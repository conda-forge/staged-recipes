#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Build JAR with ant
ant jar
cp build/artifact/jars/ivy.jar ${PREFIX}/libexec/${PKG_NAME}

# Create bash and batch wrappers
tee ${PREFIX}/bin/ivy << EOF
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/ivy/ivy.jar "\$@"
EOF

tee ${PREFIX}/bin/ivy.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\ivy\ivy.jar %*
EOF

# Use ivy to create pom.xml
chmod +x ${PREFIX}/bin/ivy
${PREFIX}/bin/ivy -makepom ${SRC_DIR}/pom.xml -properties ${SRC_DIR}/version.properties

# Fix type for dependency jsch.agentproxy and download licenses
sed -i 's?<artifactId>jsch.agentproxy</artifactId>?<artifactId>jsch.agentproxy</artifactId><type>pom</type>?' pom.xml
mvn license:download-licenses -Dgoal=download-licenses
