#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

download_licenses() {
    pom_dir=$1
    pushd ${pom_dir}
    mvn license:download-licenses -Dgoal=download-licenses
    popd
}

export -f download_licenses

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Build with maven
mvn clean verify -DskipTests -Dmaven.compiler.release=17
unzip jacoco/target/jacoco-*.zip
cp lib/*.jar ${PREFIX}/libexec/${PKG_NAME}

# Create bash and batch files
tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/jacoco/jacococli.jar "\$@"
EOF

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\jacoco/jacococli.jar %*
EOF

# Download licenses
mkdir -p target/generated-resources/licenses

pom_dirs=(
    org.jacoco.agent.rt
    org.jacoco.ant
    org.jacoco.cli
    org.jacoco.core
    org.jacoco.report
)

echo ${pom_dirs[@]} | tr ' ' '\n' | xargs -I % bash -c "download_licenses %"

find -type d -name "licenses" | grep generated-resources | grep -v "^./target" | xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'
