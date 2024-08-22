#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

download_licenses() {
    pom_file=$1
    pom_xml=$(dirname ${pom_file})/pom.xml
    mv ${pom_file} ${pom_xml}
    sed -i 's:\-SNAPSHOT.*</version>:</version>:g' ${pom_xml}
    pushd $(dirname ${pom_xml})
    mvn license:download-licenses -Dgoal=download-licenses
    popd
}

export -f download_licenses

export COURSIER_CACHE=${SRC_DIR}/.coursier
mkdir -p .ivy2
mkdir -p .sbt
mkdir -p .coursier
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Build with support for the latest minor version of all recent major versions of Scala
sbt -sbt-dir $SRC_DIR/.sbt -ivy $SRC_DIR/.ivy2 quick-publish-local
# Copy jar files from snapshot to libexec
cp -r $SRC_DIR/.ivy2/local/org.scalameta/**/**/jars/*.jar ${PREFIX}/libexec/${PKG_NAME}
# Copy dependencies from Coursier cache to libexec
sbt -sbt-dir $SRC_DIR/.sbt -ivy $SRC_DIR/.ivy2 compile 'show metals/dependencyClasspath' 2>/dev/null | \
    grep Attributed | sed 's/^[^\*]\+\* Attributed(\([^)]\+\).*/\1/g' | \
    grep .jar | \
    xargs -I % cp -r % ${PREFIX}/libexec/${PKG_NAME}

# Find .pom files and extract licenses
find .ivy2/local/org.scalameta -name "*.pom" | xargs -I % bash -c 'download_licenses %'
mkdir -p ${SRC_DIR}/target/generated-resources/licenses
find -type d -name "licenses" | grep generated-resources | grep -v "^./target" | xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'

tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -cp \${CONDA_PREFIX}/libexec/metals/* scala.meta.metals.Main "\$@"
EOF

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %JAVA_HOME%\bin\java -cp %CONDA_PREFIX%\libexec\metals\* scala.meta.metals.Main %*
EOF
