#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build archive with jar and other files
export MAVEN_OPTS="-Xmx2048m"
mvn clean install -DskipTests=True

mkdir -p ${PREFIX}/bin
cp org.eclipse.jgit.pgm/target/jgit ${PREFIX}/bin

# Create bash and batch wrappers for ltex-ls and ltex-cli
tee ${PREFIX}/bin/jgit.cmd << EOF
call %CONDA_PREFIX%\bin\jgit %*
EOF

# Download licenses for dependencies and only copy licenses for project we used
mvn license:download-licenses -Dgoal=download-licenses
cp -r org.eclipse.jgit.pgm/target/generated-resources/licenses/* target/generated-resources/licenses
