#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build with maven
touch ${BUILD_PREFIX}/lib/jvm/release
mkdir release
mvn install -DskipTests=true -Dmaven.repo.local=${SRC_DIR}

# Install JAR files
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

cp com/google/googlejavaformat/google-java-format/${PKG_VERSION}/google-java-format-${PKG_VERSION}-all-deps.jar ${PREFIX}/libexec/${PKG_NAME}/google-java-format.jar

# Create bash and batch wrappers
tee ${PREFIX}/bin/google-java-format << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/google-java-format/google-java-format.jar "\$@"
EOF

tee ${PREFIX}/bin/google-java-format.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX\libexec\google-java-format\google-java-format.jar %*
EOF

install -m 755 scripts/google-java-format-diff.py ${PREFIX}/bin/google-java-format-diff
tee ${PREFIX}/bin/google-java-format-diff.cmd << EOF
call %CONDA_PREFIX%\bin\python3 %CONDA_PREFIX\bin\google-java-format-diff %*
EOF

# Download licenses and gather them from subdirectories.
pushd core
    mvn license:download-licenses -Dgoal=download-licenses
popd
mkdir -p target/generated-resources
mv core/target/generated-resources/licenses target/generated-resources
