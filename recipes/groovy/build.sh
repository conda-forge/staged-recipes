#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

download_licenses() {
    pom_file=$1
    pom_xml=$(dirname ${pom_file})/pom.xml
    mv ${pom_file} ${pom_xml}
    pushd $(dirname ${pom_xml})
    mvn license:download-licenses -Dgoal=download-licenses
    popd
}

export -f download_licenses

env_script() {
bin_name=$(basename $1)
tee ${PREFIX}/bin/${bin_name} << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/libexec/groovy/bin/${bin_name} "\$@"
EOF
}

export -f env_script

env_script_win() {
bin_name=$(basename $1)
tee ${PREFIX}/bin/${bin_name}.cmd << EOF
call %CONDA_PREFIX%\libexec\groovy\bin\\${bin_name} %*
EOF
}

export -f env_script_win

./gradlew clean dist
mv subprojects/groovy-binary/build/distributions/apache-groovy-binary-${PKG_VERSION}.zip .
unzip apache-groovy-binary-${PKG_VERSION}.zip

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
cp -r groovy-${PKG_VERSION}/* ${PREFIX}/libexec/${PKG_NAME}

find ${PREFIX}/libexec/${PKG_NAME}/bin -type f | grep -v ".bat" | grep -v ".ico" | sort -u | xargs -I % bash -c "env_script %"
find ${PREFIX}/libexec/${PKG_NAME}/bin -type f | grep ".bat" | sort -u | xargs -I % bash -c "env_script_win %"

./gradlew publishMavenPublicationToLocalFileRepository --no-build-cache --no-scan --refresh-dependencies

find -name "*.pom" | grep -v "groovy\-binary" | xargs -I % bash -c 'download_licenses %'
mkdir -p ${SRC_DIR}/target/generated-resources/licenses
find -type d -name "licenses" | grep generated-resources | grep -v "^./target" | grep -v "groovy-bom" |  xargs -I % bash -c 'cp %/* ./target/generated-resources/licenses'
