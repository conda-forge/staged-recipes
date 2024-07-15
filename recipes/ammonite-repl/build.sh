#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Declare function for downloading licenses associated with each pom.xml using maven
download_licenses() {
    pom_file=$1
    pom_xml=$(dirname ${pom_file})/pom.xml
    mv ${pom_file} ${pom_xml}
    pushd $(dirname ${pom_xml})
    mvn license:download-licenses -Dgoal=download-licenses
    popd
}

export -f download_licenses

mkdir -p .ivy2
mkdir -p .sbt
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Build JAR files with mill
./mill -i amm[3.0.0].assembly
install -m 644 out/amm/3.0.0/assembly.dest/out.jar ${PREFIX}/libexec/${PKG_NAME}/ammonite-repl.jar

# Create pom.xml files so maven can be used to download licenses
./mill -i amm[3.0.0].publishM2Local ${SRC_DIR}/m2
find -name "*.pom" | xargs -I % bash -c 'download_licenses %'
mkdir -p ${SRC_DIR}/target/generated-resources/licenses
find -type d -name "licenses" | grep generated-resources | grep -v "^./target" | xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'

# Create bash and batch wrappers
tee ${PREFIX}/bin/amm << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/ammonite-repl/ammonite-repl.jar "\$@"
EOF

tee ${PREFIX}/bin/amm.cmd << EOF
exec %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\ammonite-repl\ammonite-repl.jar %*
EOF
